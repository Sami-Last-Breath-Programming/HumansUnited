extends State;

# Variables
var driver: CharacterBody2D;

func Entry() -> void:
	# Ship Last State
	var lastState = parent.stateManager.lastState;
	# Hud Exist 
	var hud = Manager.getHud();
	# Disable Boost, Exit Button if not player ship
	if hud and not lastState in [	
			parent.stateManager.States.EMPTY,
			parent.stateManager.States.DISABLED, 
		]: 
		hud.disableBtn(hud.Buttons.BOOST);
		hud.disableBtn(hud.Buttons.CAM_SWITCH);
	
	# Enable Particle
	parent.sinkParticle.emitting = true;
	parent.shipCamera.enabled = true;
	
	# Driver Exist
	driver = parent.getDriver();
	# Make sure Driver is not Shifted
	if driver:
		driver.global_position = parent.global_position;
		# Handle Roof Ships
		if parent.hasRoof():
			driver.visible = false;
	
	# Shrink Animation
	var tween = parent.create_tween();
	tween.set_parallel(true);
	
	# Properly ease and trans 
	tween.tween_property(parent, "scale", Vector2.ZERO, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	# Delay cleanup 
	tween.chain().tween_interval(1.4);
	
	# finished signal
	tween.finished.connect(func():
		# Driver Exist
		driver = parent.getDriver();
		if driver:
			var status = driver.takeDamage(Global.shipSinkDamage);
			# Check if drive alive 
			if (status == driver.Health.STILL): 
				# Check for ship disabled
				if (lastState == parent.stateManager.States.DISABLED):
					driver.stateManager.changeState(driver.stateManager.States.DISABLED);
				else:
					driver.stateManager.changeState(driver.stateManager.States.IDLE);
		
		# Free the ship object
		stateManager.delete();
	)
	
func Exit() -> void:
	# If Driver Exist
	driver = parent.getDriver();
	# Post Setup Driver 
	if (driver and not driver.visible):
		driver.visible = true;
	# Enable boost button
	var hud = Manager.getHud();
	# Enable Boost, Exit Button 
	if (hud): 
		hud.enableBtn(hud.Buttons.BOOST);
		hud.enableBtn(hud.Buttons.CAM_SWITCH);
	# Disable particles
	parent.sinkParticle.emitting = false;
	parent.shipCamera.enabled = false;
