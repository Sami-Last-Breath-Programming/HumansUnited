extends State

# Variables
var ship: CharacterBody2D;

func Entry() -> void:		
	# Player dead animation if not in vehicle 
	if not parent.metaData[&"inVehicle"]:
		handleDeadAnim();
		# Wait for dead animtion 
		await get_tree().create_timer(2).timeout;

	# Shrink Animation
	var tween = parent.create_tween();
	tween.set_parallel(true);

	# Properly ease and trans 
	tween.tween_property(parent, "scale", Vector2.ZERO, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	# Delay cleanup by 2 seconds 
	tween.chain().tween_interval(0.6);
	
	# finished signal
	tween.finished.connect(func():
		parent.velocity = Vector2.ZERO;
		parent.texture.visible = false;
		parent.collider.call_deferred("set_disabled", true);
		checkPlayerState();
		
		# Set Payload
		var packet: Dictionary = {&"name": parent.name}
		Manager.playerDead.emit(packet);

		# Wait for frame 
		await get_tree().process_frame;
		stateManager.delete();
	)

func handleDeadAnim() -> void:
	if abs(parent.lasDir.x) > abs(parent.lasDir.y):
		# Check Horizontal
		if parent.lasDir.x > 0.1:
			parent.animManager.play("dead_right")
		elif parent.lasDir.x < -0.1:
			parent.animManager.play("dead_left")
	else:
		# Check Vertical
		if parent.lasDir.y > 0.1:
			parent.animManager.play("dead_down")
		elif parent.lasDir.y < -0.1:
			parent.animManager.play("dead_up")

func checkPlayerState() -> void:
	if stateManager.lastState in [
		stateManager.States.IDLE, 
		stateManager.States.IN_SHIP
	]: # ADD IN PLANE
		
		# Set Payload
		var packet: Dictionary = {&"name": parent.name}
		Manager.reqPlayerSwitch.emit.call_deferred((packet));