extends Node

# Animations Types
enum Anim { SWIM, SPLASH, PLAYER};

# Lazy Load
@onready var playerTexture : AnimatedSprite2D =  $"../Texture";
@onready var outlineTexture : AnimatedSprite2D = $"../Outline";
@onready var playerSwim: AnimatedSprite2D = $"../Swim";
@onready var playerSplash: AnimatedSprite2D = $"../Splash";

func play(which: Variant) -> void:
	if which is String:
		# Play on main texture
		if playerTexture.sprite_frames:
			if playerTexture.sprite_frames.has_animation(which):
				playerTexture.play(which);
		# Play on outline texture
		if outlineTexture.sprite_frames:
			if outlineTexture.sprite_frames.has_animation(which):
				outlineTexture.play(which);
	elif which is Anim:
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
			Anim.PLAYER:
				# Stop on main texture
				if playerTexture.sprite_frames:
					if playerTexture.is_playing():
							playerTexture.stop();
				# Stop on outline texture
				if outlineTexture.sprite_frames:
					if outlineTexture.is_playing():
						outlineTexture.stop();
