extends Area2D

# Varaibles
enum {HEAD = 64, HOLDER = 128}

func handleOnTrunk(area: Area2D) -> void:
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

func handleOffTrunk(area: Area2D) -> void:
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
			if is_instance_valid(parent): parent.texture.z_index = 6;
		else :
			# Decrease z index
			var parent = node.get_parent();
			if is_instance_valid(parent): parent.texture.z_index = 3;
