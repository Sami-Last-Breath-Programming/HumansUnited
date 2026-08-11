extends State;

# Variables
enum {LAND = 1, ROCK = 2, VEHICLE = 8};
var driver: CharacterBody2D;
var canDrive: bool;

func Entry() -> void:
	# Set metaData 
	driver = parent.getDriver();
	# Set flag
	canDrive = true

	# Driver Exist
	if driver:
		# Set metaData 
		parent.metaData[&"driverId"] = driver.get_instance_id();
		parent.metaData[&"driverState"] = driver.stateManager.currentStateRef.name;
		parent.metaData[&"driverInShip"] = true;
	
	# Connect Signal 
	if (not Manager.driverExit.is_connected(handleExit)):
		Manager.driverExit.connect(handleExit);
	
	if (not Manager.cameraSwitching.is_connected(stopShip)):
		Manager.cameraSwitching.connect(stopShip);

	if (not Manager.cameraSwitched.is_connected(startShip)):
		Manager.cameraSwitched.connect(startShip);
	
	# Driver exist
	driver = parent.getDriver();
	# Set Driver as Ship child
	if (driver): 
		driver.reparent(parent);
		driver.global_position = parent.global_position;
		# Handle Roofs Ships
		if parent.hasRoof():
			driver.visible = false;
	# Set input zero
	parent.input = Vector2.ZERO;

	# Connect Detector
	parent.detector.body_entered.connect(damageBody);

func Exit() -> void:	
	# Disconnect signal 
	if (Manager.driverExit.is_connected(handleExit)):
		Manager.driverExit.disconnect(handleExit);
	
	if (Manager.cameraSwitching.is_connected(stopShip)):
		Manager.cameraSwitching.disconnect(stopShip);

	if (Manager.cameraSwitched.is_connected(startShip)):
		Manager.cameraSwitched.disconnect(startShip);
	
	# Driver exist
	driver = parent.getDriver();
	# Set Driver Child of current scene
	if (driver): 
		driver.reparent(get_tree().get_first_node_in_group("PlayersGroup"));
		driver.global_position = parent.global_position + Vector2(20, 0);
		
		# Toggle Driver Visibality
		if not driver.visible:
			driver.visible = true;
		# Remove driver reference
		if parent.getDriver():
			parent.removeDriver();

	# Stop ship
	canDrive = false;
	parent.input = Vector2.ZERO;
	parent.isBoost = false;
	parent.velocity = Vector2.ZERO;
	parent.particle.emitting = false;

	# Disconnect Detector
	parent.detector.body_entered.disconnect(damageBody);
		
	# Start exit timer
	parent.exitTimer.start(parent.exitTime);

func damageBody(body: CharacterBody2D):
	# Don't React
	if not body is CharacterBody2D: return;
	if not parent.damageTimer.is_stopped(): return;
	if parent.velocity == Vector2.ZERO: return;
	if not body.is_in_group("Player"): return;
	
	# Outside driver exist
	var outsideDriver = parent.getDriver(body);
	
	# Give Damage to driver
	if (outsideDriver): outsideDriver.takeDamage(parent.shipDamage)
	
	# Cooldown	
	parent.damageTimer.start(parent.damageTime)
	print("Damage GIven to object: ", outsideDriver);

func PhysicsUpdate(_delta: float) -> void:
	if not canDrive: return;
	
	# Change Velocity
	parent.velocity = parent.input * (parent.boostShipSpeed if parent.isBoost else parent.shipSpeed);
	
	# Handle Roatation
	if (parent.input != Vector2.ZERO):
		var angle: float = parent.input.angle() - (PI / 2);
		parent.texture.rotation = angle; 
		parent.shipCollider.rotation = angle;
		parent.particle.emitting = true;
	else:
		parent.particle.emitting = false;
	
	parent.processFriction(_delta);
	parent.move_and_slide();
	handleCollisions(_delta);

func handleCollisions(_d: float) -> void:
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
			LAND: if canDamage(): parent.takeDamage(10.0); 
			ROCK: parent.takeDamage(5.0); 
			VEHICLE: handleShip(collider);

func startShip(packet: Dictionary) -> void:
	# Wait for driver
	await get_tree().process_frame;
	# Check for driver
	driver = parent.getDriver();
	# Driver Exist
	if driver and packet[&"targetPlayer"]:
		if driver.name == packet[&"targetPlayer"].name:
			canDrive = true;

func stopShip(packet: Dictionary):
	driver = parent.getDriver();
	# Driver Exist
	if driver:
		if packet[&"lastPlayerName"] == driver.name:
			canDrive = false;
			parent.input = Vector2.ZERO;
			parent.isBoost = false;
			parent.velocity = Vector2.ZERO;
			parent.particle.emitting = false;

func handleShip(collider) -> void:
	if collider != parent:
		if collider.has_method("takeDamage"):
			# Boost Damage
			if canDamage():
				# Give damage to other ship
				collider.takeDamage(parent.shipDamage);
				# Give damage to Self
				parent.takeDamage(parent.shipDamage / 2.4);
			else:
				# Normal push 
				if parent.velocity.length_squared() >= 1400 and parent.input != Vector2.ZERO:
					# Give damage to other ship
					collider.takeDamage(parent.shipDamage);
					# Give damage to Self
					parent.takeDamage(parent.shipDamage / 4.8);

func canDamage() -> bool:
	return (parent.input != Vector2.ZERO and parent.boostShipSpeed != 0.0 and parent.isBoost)

func handleExit(packet: Dictionary) -> void:
	# Only Exit on Ship
	if packet[&"vehicle"] != &"Ship": return;
	# Get driver
	driver = parent.getDriver();
	# Driver Exist
	if driver:
		# Handel unknow driver
		if packet[&"driver"] != driver.name: return;
	# Ship State to Empty
	stateManager.changeState(stateManager.States.EMPTY);