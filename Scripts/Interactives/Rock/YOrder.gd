extends Area2D;

# Variables 
enum {HEAD = 64}

func handleAreaOnStone(area: Area2D) -> void:
	print("yes");
	if area.collision_layer == HEAD:
		setupPlayerZIndex(area, true);

func handleAreaOffStone(area: Area2D) -> void:
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
