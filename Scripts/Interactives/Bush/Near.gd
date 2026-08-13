extends Area2D;

# Lazy Load
@onready var animManager: AnimationPlayer = $"../Anim";

# Varaibles
enum {PLAYER =4, HOLDER = 128}

func handleBushAnim(body: Node2D) -> void:
	# Check if Player or NPC
	if body.collision_layer == PLAYER:
		# Check MetaData:
			if body.has_method("getMetaData"):
				var metaData = body.getMetaData();
				# Check body in required state 
				if metaData[&"state"] == &"IDLE": # Handle NPC Too
					# Play Bush Animation
					animManager.play("shake");

func handleBushAnimStop(body: Node2D) -> void:
	# Check if Player or NPC
	if body.collision_layer == PLAYER:
		# Check MetaData:
			if body.has_method("getMetaData"):
				var metaData = body.getMetaData();
				# Check body in required state 
				if metaData[&"state"] == &"IDLE": # Handle NPC Too
					# Stoo Bush Animation
					animManager.play("idle");

func handleOnBush(area: Area2D) -> void:
	# Check if Player or NPC
	if area.collision_layer == HOLDER:
		# Check MetaData:
			var player: CharacterBody2D = area.get_parent();
			if player and player.has_method("getMetaData"):
				var metaData = player.getMetaData();
				# Check body in required state 
				if metaData[&"state"] == &"IDLE": # Handle NPC Too
					# Send signal to hud
					var hud = Manager.getHud();
					hud.reqHandBtn.emit({
						&"id": self.get_parent().get_instance_id(),
						&"playerId": metaData[&"id"],
						&"show": true,
					});

func handleOffBush(area: Area2D) -> void:
	# Check if Player or NPC
	if area.collision_layer == HOLDER:
		# Check MetaData:
			var player: CharacterBody2D = area.get_parent();
			if player and player.has_method("getMetaData"):
				var metaData = player.getMetaData();
				# Check body in required state 
				if metaData[&"state"] == &"IDLE":			
					# Send signal to hud
					var hud = Manager.getHud();
					hud.reqHandBtn.emit({
						&"id": self.get_parent().get_instance_id(),
						&"playerId": metaData[&"id"],
						&"show": false,
					});
