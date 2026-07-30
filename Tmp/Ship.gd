extends CharacterBody2D;

@onready var shipCamera: Camera2D = $Camera;
@export var shipSkin: int;

func getCamera() -> Camera2D:
	return shipCamera;
	
func getSkin() -> int:
	return shipSkin;
