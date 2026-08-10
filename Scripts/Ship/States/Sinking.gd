extends State;

# Variables
var driver: CharacterBody2D;
var driveState: StringName

# Booleans
var isDriver: bool;

func Entry() -> void:
	# Check driver
	driver = parent.getDriver();
	if (
		driver and
		driver.stateManager.currentState == driver.stateManager.States.IN_SHIP
		): isDriver = true; 
	else:
		isDriver = false;

	# Emit signal 
	var packet: Dictionary = {
		&"driver": isDriver,
	}
	Manager.vehicleDestroying.emit(packet);
	
	# Enable Particle
	parent.sinkParticle.emitting = true;
	
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
		# Set vehical destroyed signal 
		Manager.vehicleDestroyed.emit(packet);
		
		# Driver Exist
		driver = instance_from_id(parent.metaData[&"driverId"]) if parent.metaData[&"driverId"] != null else null;
		if driver:
			# Only Switch if player driver 
			if (driver.metaData[&"state"] == &"IN_SHIP"):
				var packet2: Dictionary = {
					&"vehicle": &"Ship",
					&"driver": driver.name,
					&"driverPos": driver.global_position,
					&"cameraZoom": Manager.getMainCamera().zoom,
				}
				Manager.driverExit.emit(packet2);
			driver.takeDamage.call_deferred(Global.shipSinkDamage);
	
		# Free the ship object
		await get_tree().create_timer(0.4).timeout;
		stateManager.delete();
	)
	
func Exit() -> void:
	# If Driver Exist
	driver = parent.getDriver();
	# Post Setup Driver 
	if (driver and not driver.visible):
		driver.visible = true;
	# Disable particles
	parent.sinkParticle.emitting = false;
