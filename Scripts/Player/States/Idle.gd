extends State

# Variables
var anim: Node;
var speed: Vector2;
var ground: TileMapLayer;
enum {WATER = 16};

# Booleans
var isBoost = false;
var inWater = false;
var isEntredWater = false;
var isSubmerge = false;

func Entry() -> void:
	# Set Name Color
	parent.setNameColor("#f3e703");
	
	# Connect Signal 
	if (not Manager.driverEnter.is_connected(handleVehicle)):
		Manager.driverEnter.connect(handleVehicle);
	
	# Connect Lambda Signal
	Manager.cameraSwitching.connect(func(packet: Dictionary):
		# Check if self request
		if packet[&"lastPlayerName"] == parent.name:
			stateManager.changeState(stateManager.States.DISABLED),
		
		CONNECT_ONE_SHOT	
	);

	# Set metaData
	parent.metaData[&"state"] = self.name;
	parent.metaData[&"inVehicle"] = false;
	parent.metaData[&"vehicleType"] = null;
	parent.metaData[&"vehicleId"] = null;
	
	# Signal To Manager
	Manager.playerIdle.emit.call_deferred(parent);
	
	# TileMapLayer setup
	ground = parent.getGround();
	
	# Player Setup
	parent.setPlayerSkin(parent.SkinType.SKIN);
	parent.collider.call_deferred("set_disabled", false);
	# Animation setup
	anim = parent.animManager;
	
func Exit() -> void:	
	# Remove Color 
	parent.setNameColor("#f0f0f0")
	
	# Disconnect signal 
	if Manager.driverEnter.is_connected(handleVehicle):
		Manager.driverEnter.disconnect(handleVehicle);

	# Disable Effects
	parent.dust.emitting = false;
	parent.showOutLine(false);
	# Disable Water Effects 
	if inWater:
		anim.stop(anim.Anim.SPLASH);
		anim.stop(anim.Anim.SWIM);
		isEntredWater = false;
		isSubmerge = false;
	# Disable Collider
	parent.collider.call_deferred("set_disabled", true);

func HandleInput(_e: InputEvent) -> void:
	if _e.is_action_pressed("CameraSwitch"): reqSwitch()	
	elif  _e.is_action_pressed("Boost"): isBoost = true;
	elif _e.is_action_released("Boost"): isBoost = false

func PhysicsUpdate(_d: float) -> void:
	# Check 
	checkWater();
	
	# Get Movement
	var input = Input.get_vector(
		"Left", "Right", "Up", 
		"Down"
	);
			
	# Handle Rotation, Particles & Animation
	if (input != Vector2.ZERO):
		# Check for water
		if inWater: 
			anim.play(anim.Anim.SWIM);
			handleWaterAnim(input);
			parent.dust.emitting = false;
			speed = input * ((Global.playerRunSpeed / 2) if isBoost else (Global.playerSpeed / 4));
		else: 
			parent.dust.emitting = true;
			handleAnim(input, true);
			speed = input * (Global.playerRunSpeed if isBoost else Global.playerSpeed);
	else:
		speed = input;
		parent.dust.emitting = false;
		if inWater: anim.stop(anim.Anim.SWIM);
		else: handleAnim(input, false);
	
	# Movement
	parent.velocity = speed;
	parent.move_and_slide();

func handleAnim(input: Vector2, yes: bool) -> void:
	if yes:
		if abs(input.x) > abs(input.y):
			# Check Horizontal
			if input.x > 0.1:
				parent.animManager.play("walk_right")
			elif input.x < -0.1:
				parent.animManager.play("walk_left")
		else:
			# Check Vertical
			if input.y > 0.1:
				parent.animManager.play("walk_down")
			elif input.y < -0.1:
				parent.animManager.play("walk_up")
	else:
		if abs(parent.lasDir.x) > abs(parent.lasDir.y):
			# Check Horizontal
			if parent.lasDir.x > 0.1:
				parent.animManager.play("idle_right")
			elif parent.lasDir.x < -0.1:
				parent.animManager.play("idle_left")
		else:
			# Check Vertical
			if parent.lasDir.y > 0.1:
				parent.animManager.play("idle_down")
			elif parent.lasDir.y < -0.1:
				parent.animManager.play("idle_up")

func handleWaterAnim(input: Vector2) -> void:
	# Request Weapon Water Animation 
	parent.animManager.weaponPlay("water");
	# Request Player Water Animation
	if abs(input.x) > abs(input.y):
		# Check Horizontal
		if input.x > 0.1:
			parent.animManager.play("idle_right");
		elif input.x < -0.1:
			parent.animManager.play("idle_left");
	else:
		# Check Vertical
		if input.y > 0.1:
			parent.animManager.play("idle_down");
		elif input.y < -0.1:
			parent.animManager.play("idle_up");

func checkWater() -> void:
	# If Ground Exits
	if ground:
		# Player feet position
		var local_pos = ground.local_to_map(parent.global_position);
		# Get ground tile 
		var g_tile = ground.get_cell_source_id(local_pos);
		# Check if on ground tile 
		if g_tile != -1: 
			# Check for submerge
			if isSubmerge:
				parent.call_deferred("setPlayerSkin", parent.SkinType.SKIN);
				isSubmerge = false;
			# Player water animations stop
			if inWater:
				anim.stop(anim.Anim.SWIM);	
				inWater = false;
			# Set Flag
			isEntredWater = false;
		else: 
			if isEntredWater and parent.isEntredWaterTimer.is_stopped(): 
				anim.stop(anim.Anim.SPLASH);
			if not isEntredWater:
				# Check for submerge
				if not isSubmerge:
					parent.call_deferred("setPlayerSkin", parent.SkinType.BOAT);
					isSubmerge = true;
				# Player water animations
				anim.play(anim.Anim.SPLASH);
				parent.isEntredWaterTimer.start(1);
				isEntredWater = true;
				inWater = true;
		
func reqSwitch() -> void:
	# Update metadata
	parent.metaData[&"isSwiching"] = true;
	
	# Payload
	var packet: Dictionary = {&"name": parent.name,}
	Manager.reqCamList.emit(packet);

func handleVehicle(packet: Dictionary):
	# Match Vehicle
	match packet[&"vehicle"]:
		&"Ship":
			var ship: CharacterBody2D = instance_from_id(packet[&"id"]) as CharacterBody2D;
			if ship:
				parent.setVehicle(ship);
				stateManager.changeState(stateManager.States.IN_SHIP);
		&"Plane":
			stateManager.changeState(stateManager.States.IN_PLANE); # Todo
	# Disconnect Signal
	if (Manager.driverEnter.is_connected(handleVehicle)):
		Manager.driverEnter.disconnect(handleVehicle);
