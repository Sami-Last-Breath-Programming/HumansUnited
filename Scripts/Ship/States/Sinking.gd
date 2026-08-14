extends State;

# Variables
var driver: CharacterBody2D;
var driveState: StringName

# Booleans
var isDriver: bool;

func Entry() -> void:
	# Check driver
	driver = instance_from_id(parent.metaData.get(&"driverId"));
	if driver:
		# Make sure Driver is not Shifted
		driver.global_position = parent.global_position;
		# Handle Roof Ships
		if parent.hasRoof():
			driver.visible = false;
		# Check if driver was in ship
		var metaData = driver.getMetaData();
		if metaData[&"state"] == &"IN_SHIP":
			# Handel SwitchList open
			var hud = Manager.getHud();
			if hud.isCamList:
				Manager.reqCamList.emit({
					&"name": driver.name,
				})
			# Wait for camList to hide
			await get_tree().create_timer(1).timeout;
			# Set driver true
			isDriver = true;
	else: isDriver = false;

	# Emit signal 
	var packet: Dictionary = {
		&"driver": isDriver,

	}
	Manager.vehicleDestroying.emit(packet);
	
	# Enable Particle
	parent.sinkParticle.emitting = true;
	
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
			else:
				# Clear metaData
				if driver.has_method("clearMetaData"):
					driver.clearMetaData();
				
			# Give Damage to driver
			if driver.has_method("takeDamage"):
				driver.takeDamage(Global.shipSinkDamage);
	
		# Free the ship object
		await get_tree().create_timer(0.4).timeout;
		stateManager.delete();
	)
	
func Exit() -> void:
	# If Driver Exist
	driver = instance_from_id(parent.metaData.get(&"driverId"));
	# Post Setup Driver 
	if (driver and not driver.visible):
		driver.visible = true;
	# Disable particles
	parent.sinkParticle.emitting = false;
