extends Area2D;

# Varaibles
enum {HOLDER = 128}
var alreadyPlayerId: int = -1;

# Booleans 
var isAlreadyPlayer: bool = false;

func handleOnStone(area: Area2D) -> void:
	# Check if Player or NPC
	if area.collision_layer == HOLDER:
		# Check MetaData:
			var player: CharacterBody2D = area.get_parent();
			if player and player.has_method("getMetaData"):
				var metaData = player.getMetaData();
				# Check body in required state 
				if metaData[&"state"] == &"IDLE": # Handle NPC Too
					# Handle more then one player
					if isAlreadyPlayer and alreadyPlayerId != metaData[&"id"]: return;
					# Set flag 
					isAlreadyPlayer = true;
					# Cache the player
					alreadyPlayerId = metaData[&"id"];
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
					# Handle more then one player
					if isAlreadyPlayer and alreadyPlayerId != metaData[&"id"]: return;
					# Set flag 
					isAlreadyPlayer = false;
					# Reset cache 
					alreadyPlayerId = -1;
					# Send signal to hud
					var hud = Manager.getHud();
					hud.reqHandBtn.emit({
						&"id": self.get_parent().get_instance_id(),
						&"playerId": metaData[&"id"],
						&"show": false,
					});
