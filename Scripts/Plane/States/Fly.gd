extends State;

# Variables
enum {ROCK = 2, SHIP = 8};
var driver: CharacterBody2D;

# Booleans 
var isBoost: bool = false

func Entry() -> void:
	var hud = Manager.getHud();
	# Hud Exist
	if hud:
		hud.enableBtn.call_deferred(hud.Buttons.BOOST);
		hud.enableBtn.call_deferred(hud.Buttons.SHIP_EXIT); # Set to Plane Exit
	
	# Driver exist
	driver = parent.getDriver();
	# Set Driver as Plane child
	if (driver): 
		driver.reparent(parent);
		driver.global_position = parent.global_position;
		
		# TODO: Set plane Reference in Driver
		if not driver.getShip():
			driver.setShip(parent);
			
		# Handle driver
		driver.visible = false;

	# Setup ship
	parent.texture.z_index = 4;
	parent.planeCamera.enabled = true;
	parent.planeCamera.make_current();

	# Connect Detector
	parent.detector.body_entered.connect(damageBody);

func Exit() -> void:
	# Set Plane Camera False
	parent.planeCamera.enabled = false;
	
	# Driver exist
	driver = parent.getDriver();
	# Set Driver Child of current scene
	if (driver): 
		driver.reparent(get_tree().current_scene.get_node("Y-Order"));
		driver.global_position = parent.global_position + Vector2(20, 0);
		
		# Remove the plane reference from driver
		if driver.getShip():   # TODO: Do for plane 
			driver.removeShip();
		
		# Toggle Driver Visibality
		if not driver.visible:
			driver.visible = true;

	# Disconnect Detector
	parent.detector.body_entered.disconnect(damageBody);
	
	# Hide plane exit button 
	var hud = Manager.getHud();
	# Hud Exist
	if hud: hud.disableBtn(hud.Buttons.SHIP_EXIT); # Set to Plane Exit
		
	# Start exit timer
	parent.exitTimer.start(parent.exitTime);

func damageBody(body: CharacterBody2D):
	if true: return;
    # Don't React
	if not body is CharacterBody2D: return;
	if not parent.damageTimer.is_stopped(): return;
	if parent.velocity == Vector2.ZERO: return;
	if not body.is_in_group("Player"): return;
	
	# Outside driver exist
	var outsideDriver = parent.getDriver(body);
	
	# Give Damage to driver
	if (outsideDriver):
		outsideDriver.takeDamage(parent.planeDamage)
	
	# Cooldown	
	parent.damageTimer.start(parent.damageTime)

func HandleInput(_e: InputEvent) -> void:
	# Handle Plane Exit
	if _e.is_action_pressed("ShipExit"): # Set to Exit 
		# Driver Exist
		driver = parent.getDriver();
		# Handle Drive State 
		if (driver):
			driver.stateManager.changeState(driver.stateManager.States.IDLE);
		
		# Plane State to Idle
		stateManager.changeState(stateManager.States.IDLE);
	
	# Handle Driving Boost
	if _e.is_action_pressed("Boost"):
		if (parent.planeBoostSpeed != 0.0): isBoost = true;
	elif _e.is_action_released("Boost"): isBoost = false;

func PhysicsUpdate(_delta: float) -> void:
	# Change Velocity
	var input = getInput();
	parent.velocity = input * (parent.planeBoostSpeed if isBoost else parent.planeSpeed);

	# Handle Roatation
	if (input != Vector2.ZERO):
		var angle: float = input.angle() - (PI / 2);
		parent.texture.rotation = angle;
		parent.planeCollider.rotation = angle;
		parent.planeWingsCollider.rotation = angle;
	else:
		pass; # Particle Handle here

	parent.processFriction(_delta);
	parent.move_and_slide();
	handleCollisions(input, _delta);

func getInput() -> Vector2:
	var input =  Input.get_vector("Left", "Right", "Up", "Down");
	return input;

func handleCollisions(input: Vector2, _d: float) -> void:
	var layer: int;
	# Loop over the collisions array
	for index in parent.get_slide_collision_count():
		var collision: KinematicCollision2D = parent.get_slide_collision(index);
		var collider: Object = collision.get_collider();
		if not collider: continue;
		# Get Collision Layer
		if collider is TileMapLayer:
			layer = collider.tile_set.get_physics_layer_collision_layer(0);
		else:
			layer = collider.collision_layer
		# Check Collision Type
		match layer:
			# Check for Water
			ROCK: parent.takeDamage(5.0); 
			SHIP: handleShip(collider, input);
			
func handleShip(collider, input) -> void:
	if collider != parent:
		if collider.has_method("takeDamage"):
			# Boost Damage
			if canDamage(input):
				# Give damage to other ship
				collider.takeDamage(parent.planeDamage);
				# Give damage to Self
				parent.takeDamage(parent.planeDamage / 2.4);
			else:
				# Normal push 
				if parent.velocity.length_squared() >= 1400 and input != Vector2.ZERO:
					# Give damage to other ship
					collider.takeDamage(parent.planeDamage);
					# Give damage to Self
					parent.takeDamage(parent.planeDamage / 4.8);

func canDamage(input: Vector2) -> bool:
	return (input != Vector2.ZERO and parent.planeBoostSpeed != 0.0 and isBoost)
