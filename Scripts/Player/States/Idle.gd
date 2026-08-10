extends State

# Variables
var anim: Node;
var ground: TileMapLayer;
var floraLayer: TileMapLayer;
enum {WATER = 16};

# Booleans
var isBoost = false;
var inWater = false;
var isEntredWater = false;
var isSubmerge = false;

func Entry() -> void:
	# Connect Signal 
	if (not Manager.driverEnter.is_connected(handleVehicle)):
		Manager.driverEnter.connect(handleVehicle);
	
	# Connect Lambda Signal
	Manager.cameraSwitching.connect(func():
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
	floraLayer = parent.getFlora();
	
	# Player Setup
	parent.setPlayerSkin(parent.SkinType.SKIN);
	parent.collider.call_deferred("set_disabled", false);
	# Animation setup
	anim = parent.animManager;
	
func Exit() -> void:	
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
	# Process outline 
	parent.processOutline();

	# Check 
	checkWater();
	checkTree();
	
	# Get Movement
	var input = Input.get_vector(
		"Left", "Right", "Up", 
		"Down"
	);
			
	# Handle Rotation, Particles & Animation
	if (input != Vector2.ZERO):
		if inWater: 
			anim.play(anim.Anim.SWIM);
			parent.dust.emitting = false;
		else: parent.dust.emitting = true;
	else:
		parent.dust.emitting = false;
		if inWater: anim.stop(anim.Anim.SWIM);
	
	# Movement
	parent.velocity = input * (Global.playerRunSpeed if isBoost else Global.playerSpeed);
	parent.move_and_slide();

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

func checkTree() -> void:
	# If flora Exist
	if floraLayer:
		# Player feet position
		var local_pos = floraLayer.local_to_map(parent.global_position);
		# Get flora tile
		var f_tile = floraLayer.get_cell_source_id(local_pos);
		# Check if on flora tile 
		if f_tile != -1: parent.showOutLine(true);
		else: parent.showOutLine(false);
		
func reqSwitch() -> void:
	# Payload
	var packet: Dictionary = {&"name": parent.name,}
	Manager.reqCamList.emit(packet);

func handleVehicle(packet: Dictionary):
	# Match Vehicle
	match packet[&"vehicle"]:
		&"Ship":
			var ship: CharacterBody2D = instance_from_id(packet[&"id"]) as CharacterBody2D;
			print(ship);
			if ship:
				parent.setVehicle(ship);
				stateManager.changeState(stateManager.States.IN_SHIP);
				print("to-ship-now");
		&"Plane":
			stateManager.changeState(stateManager.States.IN_PLANE); # Todo
	# Disconnect Signal
	if (Manager.driverEnter.is_connected(handleVehicle)):
		Manager.driverEnter.disconnect(handleVehicle);
