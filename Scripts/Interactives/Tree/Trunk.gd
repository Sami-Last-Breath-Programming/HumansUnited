extends Area2D

# Varaibles
enum {HEAD = 64, HOLDER = 128}
var alreadyPlayerId: int = -1;

# Booleans 
var isAlreadyPlayer: bool = false;

func handleOnTrunk(area: Area2D) -> void:
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

func handleOffTrunk(area: Area2D) -> void:
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
					# Stop weapon anim 
					if player.has_method("getWeapon"):
						var weapon: Node2D = player.getWeapon();
						if weapon and weapon.has_method("stopAction"):
							weapon.stopAction(); 
					# Sent siganl tom hud
					var hud = Manager.getHud();
					hud.reqHandBtn.emit({
						&"id": self.get_parent().get_instance_id(),
						&"playerId": metaData[&"id"],
						&"show": false,
					});

func handleAreaOnTrunk(area: Area2D) -> void:
	if area.collision_layer == HEAD:
		setupPlayerZIndex(area, true);

func handleAreaOffTrunk(area: Area2D) -> void:
	if area.collision_layer == HEAD:
		setupPlayerZIndex(area, false);

func setupPlayerZIndex(node: Variant, yes: bool) -> void:
	# Check if Player or NPC
	if node.is_in_group("Player"):
		if yes:
			# Increase z index
			var parent = node.get_parent();
			if is_instance_valid(parent) and parent.has_method("setZOrder"):
				parent.setZOrder(7);
		else :
			# Decrease z index
			var parent = node.get_parent();
			if is_instance_valid(parent) and parent.has_method("setZOrder"): 
				parent.setZOrder(&"Default");
