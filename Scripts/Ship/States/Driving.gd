extends State;

# Variables
var driver: CharacterBody2D;

# Booleans
var isBoost: bool = false;

func Entry() -> void:
	# Driver exist
	driver = parent.getDriver();
	# Set Driver as Ship child
	if (driver): 
		driver.reparent(parent);
		driver.global_position = parent.global_position;
		
		# Set Ship Reference in Driver
		if not driver.getShip():
			driver.setShip(parent);
			
		# Handle Roofs Ships
		if parent.hasRoof():
			driver.visible = false;
		
	# Setup ship
	parent.shipCamera.enabled = true;
	parent.shipCamera.make_current();
	# Connect Detector
	parent.detector.body_entered.connect(damageBody);

func Exit() -> void:
	# Set Ship Camera False
	parent.shipCamera.enabled = false;
	parent.particle.emitting = false;
	
	# Driver exist
	driver = parent.getDriver();
	# Set Driver Child of current scene
	if (driver): 
		driver.reparent(get_tree().current_scene);
		driver.global_position = parent.global_position + Vector2(20, 0);
		
		# Remove the Ship reference from driver
		if driver.getShip():
			driver.removeShip();
		
		# Toggle Driver Visibality
		if not driver.visible:
			driver.visible = true;
	
	# Disconnect Detector
	parent.detector.body_entered.disconnect(damageBody);
	
	# Hide ship exit button 
	var hud = Manager.getHud();
	# Hud Exist
	if (hud):
		hud.hideShipExit();
		hud.enableBtn("Boost");
	
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
	if (outsideDriver):
		outsideDriver.takeDamage(parent.shipDamage)
	
	# Cooldown	
	parent.damageTimer.start(parent.damageTime)
	print("Damage GIven to object: ", outsideDriver);
	
func HandleInput(_e: InputEvent) -> void:
	# Handle Ship Exit
	if _e.is_action_pressed("ShipExit"):
		# Driver Exist
		driver = parent.getDriver();
		# Handle Drive State 
		if (driver):
			driver.stateManager.changeState(driver.stateManager.States.IDLE);
		
		# Ship State to Empty
		stateManager.changeState(stateManager.States.EMPTY);
	
	# Handle Driving Boost
	if _e.is_action_pressed("Boost"):
		if (parent.boostShipSpeed != 0.0): isBoost = true;
	elif _e.is_action_released("Boost"): isBoost = false;

func PhysicsUpdate(_delta: float) -> void:
	# Change Velocity
	var input = getInput();
	parent.velocity = input * (parent.boostShipSpeed if isBoost else parent.shipSpeed);
	
	# Handle Roatation
	if (input != Vector2.ZERO):
		var angle: float = input.angle() - (PI / 2);
		parent.texture.rotation = angle; 
		parent.shipCollider.rotation = angle;
		parent.particle.emitting = true;
	else:
		parent.particle.emitting = false;
	
	parent.processFriction(_delta);
	parent.move_and_slide();
	handleCollisions(input, _delta);

func getInput() -> Vector2:
	var input =  Input.get_vector("Left", "Right", "Up", "Down");
	return input if (input != Vector2.ZERO) else parent.external_input;

func handleCollisions(input: Vector2, _d: float) -> void:
	# Loop over the collisions array
	for index in parent.get_slide_collision_count():
		var collision = parent.get_slide_collision(index);
		var collider = collision.get_collider();
		var tileData = getTileData(collider, collision); 

		# Check for other ships
		if collider and collider.is_in_group("Ship"):
			# If other ship not self
			if collider != parent:
				if collider.has_method("takeDamage"):
					# Boost Damage
					if canDamage(input):
						# Give damage to other ship
						collider.takeDamage(parent.shipDamage);
						# Give damage to Self
						parent.takeDamage(parent.shipDamage / 2.4);
						print("Given damage to: ", collider);
					else:
						# Normal push 
						if parent.velocity.length_squared() >= 1400 and input != Vector2.ZERO:
							# Give damage to other ship
							collider.takeDamage(parent.shipDamage);
							# Give damage to Self
							parent.takeDamage(parent.shipDamage / 4.8);
							print("Given damage to: ", collider);
					
		# Check the tiledata
		if tileData:
			var tileType = tileData.get_custom_data("type");
			if checkObjectCollided(tileType, canDamage(input)): break;
		
func getTileData(collider, collision) -> TileData:
	# Check if collider is a tilemaplayer
	if (collider is TileMapLayer):
		var impact_point = collision.get_position() - (collision.get_normal() * 2.0);
		var tile_coords = collider.local_to_map(collider.to_local(impact_point));
		return collider.get_cell_tile_data(tile_coords);
	return null;	
	
func checkObjectCollided(tileType, d) -> bool:
	var isobj: bool;
	# Handel Logic of Objects
	match tileType:
		"land": 
			if d: 
				parent.takeDamage(10.0); 
				print("Ship Collided with Land: ", parent);
				isobj = true;
		"stone": 
			parent.takeDamage(5.0); 
			print("Ship Collided with Stone: ", parent);
			isobj = true;
		_: isobj = false;

	return isobj;

func canDamage(input: Vector2) -> bool:
	return (input != Vector2.ZERO and parent.boostShipSpeed != 0.0 and isBoost)
