extends State;

# Variables
var ship = parent as CharacterBody2D;
var driver: CharacterBody2D;

func Entry() -> void:
	# Enable Particle
	ship.sinkParticle.emitting = true;
	ship.shipCamera.enabled = true;
	
	# Driver Exist
	driver = ship.getDriver();
	# Make sure Driver is not Shifted
	if (driver):
		driver.global_position = ship.global_position;
		
		# Handle Roof Ships
		if ship.hasRoof():
			driver.visible = false;
	
	# Shrink Animation
	var tween = ship.create_tween();
	tween.set_parallel(true);
	
	# Properly ease and trans 
	tween.tween_property(ship, "scale", Vector2.ZERO, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	# Delay cleanup 
	tween.chain().tween_interval(1.4);
	
	# finished signal
	tween.finished.connect(func():
		# Driver Exist
		driver = ship.getDriver();
		if (driver):
			var status = driver.takeDamage(Global.shipSinkDamage);
			# Check if drive alive 
			if (status == driver.Health.STILL): 
				driver.stateManager.changeState(ship.driver.stateManager.States.IDLE)
		
		# Free the ship object
		stateManager.delete();
	)
	
func Exit() -> void:
	# Post Setup Driver 
	if (not driver.visible):
		driver.visible = true;
		
	ship.sinkParticle.emitting = false;
	ship.shipCamera.enabled = false;
