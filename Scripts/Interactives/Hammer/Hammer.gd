extends Node2D;

# Lazy Load 
@onready var body: Sprite2D = $Texture;
@onready var animManager: AnimationPlayer = $Anim;
@onready var outline: Sprite2D = $Outline;

func getAnimManager() -> AnimationPlayer:
	return animManager;

func showOutline(flag: bool) -> void:
	if flag:
		outline.visible = true;
		outline.flip_v = body.flip_v
		outline.rotation = body.rotation;
		outline.position = body.position;
	else:
		outline.visible = false;
