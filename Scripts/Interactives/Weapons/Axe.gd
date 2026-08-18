extends Node2D;

# Lazy Load 
@onready var body: Sprite2D = $Texture;
@onready var animManager: AnimationPlayer = $Anim;
@onready var outline: Sprite2D = $Outline;

# Variables 
var player: CharacterBody2D = null;

func _ready() -> void:
	player = self.owner;

func doAction():
	handleAnim();

func stopAction():
	animManager.stop();

func handleAnim() -> void:
	# Player Exist
	if player:
		if abs(player.lasDir.x) > abs(player.lasDir.y):
			# Check Horizontal
			if player.lasDir.x > 0.1:
				animManager.play("attack_right");
			elif player.lasDir.x < -0.1:
				animManager.play("attack_left");
		else:
			# Check Vertical
			if player.lasDir.y > 0.1:
				animManager.play("attack_down");
			elif player.lasDir.y < -0.1:
				animManager.play("attack_up");

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
