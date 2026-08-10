extends State;

# Variables
var ship: CharacterBody2D;

func Entry() -> void:
	parent.collider.call_deferred("set_disabled", false); 
	
func Exit() -> void:
	parent.collider.call_deferred("set_disabled", true); 
