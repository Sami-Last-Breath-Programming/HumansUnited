extends Area2D;

# Varaibles
enum {HOLDER = 128}

func handleOnStone(area: Area2D) -> void:
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

func handleOffStone(area: Area2D) -> void:
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
