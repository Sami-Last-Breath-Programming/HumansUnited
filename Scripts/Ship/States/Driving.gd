extends State;

# Variables
var ship = parent as CharacterBody2D;
var driver: CharacterBody2D;

# Booleans
var isBoost: bool = false;

func Entry() -> void:
	# Driver exist
	driver = ship.getDriver();
	# Set Driver as Ship child
	if (driver): 
		driver.reparent(ship);
		driver.global_position = ship.global_position;
		
		# Set Ship Reference in Driver
		if not driver.getShip():
			driver.setShip(ship);
			
		# Handle Roofs Ships
		if ship.hasRoof():
			driver.visible = false;
		
	# Setup ship
	ship.shipCamera.enabled = true;
	ship.shipCamera.make_current();
	# Connect Detector
	ship.detector.body_entered.connect(damageBody);

func Exit() -> void:
	# Set Ship Camera False
	ship.shipCamera.enabled = false;
	ship.particle.emitting = false;
	
	# Driver exist
	driver = ship.getDriver();
	# Set Driver Child of current scene
	if (driver): 
		driver.reparent(get_tree().current_scene);
		driver.global_position = ship.global_position + Vector2(20, 0);
		
		# Remove the Ship reference from driver
		if driver.getShip():
			driver.removeShip();
		
		# Toggle Driver Visibality
		if (not driver.visible):
			driver.visible = true;
	# Disconnect Detector
	ship.detector.body_entered.disconnect(damageBody);
	
	# Start exit timer
	ship.exitTimer.start(ship.exitTime);

func damageBody(body: CharacterBody2D):
	if not body is CharacterBody2D: return;
	if not ship.damageTimer.is_stopped(): return;
	if ship.velocity == Vector2.ZERO: return;
	
	# Outside driver exist
	var outsideDriver = ship.getDriver(body);
	
	# Give Damage to driver
	if (outsideDriver):
		outsideDriver.takeDamage(ship.shipDamage)
	
	# Cooldown	
	ship.damageTimer.start(ship.damageTime)
	print("Damage GIven")
	
func HandleInput(_e: InputEvent) -> void:
	# Handle Ship Exit
	if _e.is_action_pressed("ShipExit"):
		# Driver Exist
		driver = ship.getDriver();
		# Handle Drive State 
		if (driver):
			driver.stateManager.changeState(driver.stateManager.States.IDLE);
		
		# Ship State to Empty
		stateManager.changeState(stateManager.States.EMPTY);
	
	# Handle Driving Boost
	if _e.is_action_pressed("Boost"):
		if (ship.boostShipSpeed != 0.0): isBoost = true;
	elif _e.is_action_released("Boost"): isBoost = false;

func PhysicsUpdate(_delta: float) -> void:
	# Change Velocity
	var input = getInput();
	ship.velocity = input * (ship.boostShipSpeed if isBoost else ship.shipSpeed);
	
	# Handle Roatation
	if (input != Vector2.ZERO):
		var angle: float = input.angle() - (PI / 2);
		ship.texture.rotation = angle; 
		ship.shipCollider.rotation = angle;
		ship.particle.emitting = true;
	else:
		ship.particle.emitting = false;
	
	ship.move_and_slide();
	handleCollisions(input);

func getInput() -> Vector2:
	var input =  Input.get_vector("Left", "Right", "Up", "Down");
	return input if (input != Vector2.ZERO) else ship.external_input;

func handleCollisions(input: Vector2) -> void:
	# Loop over the collisions array
	for index in ship.get_slide_collision_count():
		var collision = ship.get_slide_collision(index);
		var collider = collision.get_collider();
		var tileData = getTileData(collider, collision); 
		
		# Check the tiledata
		if tileData:
			var tileType = tileData.get_custom_data("type");
			var canDamage = input != Vector2.ZERO and ship.boostShipSpeed != 0.0 and isBoost;
			if checkObjectCollided(tileType, canDamage): break;
		
func getTileData(collider, collision) -> TileData:
	# Check if collider is a tilemaplayer
	if (collider is TileMapLayer):
		var impact_point = collision.get_position() - (collision.get_normal() * 2.0);
		var tile_coords = collider.local_to_map(collider.to_local(impact_point));
		return collider.get_cell_tile_data(tile_coords);
	return null;	
	
func checkObjectCollided(tileType, canDamage) -> bool:
	var isobj: bool;
	# Handel Logic of Objects
	match tileType:
		"land": if canDamage: ship.takeDamage(10.0); isobj = true;
		"stone": ship.takeDamage(5.0); isobj = true;
		_: isobj = false;

	return isobj;
