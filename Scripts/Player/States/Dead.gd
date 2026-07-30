extends State

# Variables
var player = parent as CharacterBody2D;;
var ship: CharacterBody2D;

func Entry() -> void:
	# Shrink Animation
	player.camera.enabled = true;
	var tween = player.create_tween();
	tween.set_parallel(true);
	
	# Properly ease and trans 
	tween.tween_property(player, "scale", Vector2.ZERO, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	# Delay cleanup by 2 seconds 
	tween.chain().tween_interval(0.6);
	
	# finished signal
	tween.finished.connect(func():
		player.velocity = Vector2.ZERO;
					
		# Handle Ship Dead
		if (stateManager.lastState in [stateManager.States.IDLE, stateManager.States.IN_SHIP]):
			Manager.reqPlayerSwitch.emit(player);
		
		# Delete Self	
		stateManager.delete();
	)

func Exit() -> void:
	player.camera.enabled = false;
