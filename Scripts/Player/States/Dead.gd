extends State

# Variables
var ship: CharacterBody2D;

func Entry() -> void:
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
		parent.visible = false;
		
		# Set Payload
		var packet: Dictionary = {&"name": parent.name}
		Manager.playerDead.emit(packet);
		checkPlayerState();
		stateManager.delete();
	)
func checkPlayerState() -> void:
	if stateManager.lastState in [
		stateManager.States.IDLE, 
		stateManager.States.IN_SHIP
	]: # ADD IN PLANE
		
		# Set Payload
		var packet: Dictionary = {&"name": parent.name}
		Manager.reqPlayerSwitch.emit.call_deferred((packet));