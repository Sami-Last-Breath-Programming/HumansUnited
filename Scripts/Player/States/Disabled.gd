extends State;

# Variables
var player = parent as CharacterBody2D;;
var ship: CharacterBody2D;

func Entry() -> void:
	player.camera.enabled = false;
	player.collider.call_deferred("set_disabled", false); 
	
func Exit() -> void:
	player.collider.call_deferred("set_disabled", true); 
