extends Area2D;

func handleOnLeaves(body: CharacterBody2D) -> void:
	# Check if Player or NPC
	if body.is_in_group("Player"):
		# Check MetaData and show outline
		if  body.has_method("getMetaData") and body.has_method("showOutLine") \
			and body.has_method("processOutline"):
			var metaData = body.getMetaData();
			# Only show outline if not Npc or not disabled
			if metaData[&"state"] == &"IDLE":
				body.showOutLine(true);

func handleOffLeaves(body: CharacterBody2D) -> void:
	# Check if Player or NPC
	if body.is_in_group("Player"):
		# Check MetaData and show outline
		if  body.has_method("getMetaData") and body.has_method("showOutLine"):
			var metaData = body.getMetaData();
			# Only show outline if not Npc or not disabled
			if metaData[&"state"] == &"IDLE":
				body.showOutLine(false);
