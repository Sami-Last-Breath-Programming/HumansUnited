extends State

# Variables
var ship: CharacterBody2D;

func Entry() -> void:
	# Shrink Animation
	parent.camera.enabled = true;
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
					
		# Handle Ship Dead
		if (stateManager.lastState in [stateManager.States.IDLE, stateManager.States.IN_SHIP]):
			Manager.reqPlayerSwitch.emit(parent);
		
		# Delete Self	
		stateManager.delete();
	)

func Exit() -> void:
	parent.camera.enabled = false;
