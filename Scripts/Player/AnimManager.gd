extends Node

# Animations Types
enum Anim { SWIM, SPLASH}

# Lazy Load
@onready var playerTexture := $"../Texture"
@onready var playerSwim: AnimatedSprite2D = $"../Swim"
@onready var playerSplash: AnimatedSprite2D = $"../Splash"

func play(which: Anim) -> void:
	match which:
		Anim.SWIM: 
			playerSwim.visible = true;
			playerSwim.play("swim");
		Anim.SPLASH:
			playerSplash.visible = true;
			playerSplash.play("splash");

func stop(which: Anim) -> void:
	match which:
		Anim.SWIM: 
			playerSwim.stop();
			playerSwim.visible = false;
		Anim.SPLASH:
			playerSplash.stop();
			playerSplash.visible = false;
