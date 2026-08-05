extends Node

#Lazy Load 
@onready var camListEntry: PackedScene = preload("res://Scenes/UI/CamListEntry.tscn");
@onready var vHolder: VBoxContainer = $BG/Scroll/Vbox

func fetch(currentPlayer: CharacterBody2D) -> void:
	# Find all players 
	var players: Array[Node] = get_tree().get_nodes_in_group("Player");
	# Init the CamList Entry
	for player in players:
		if player is CharacterBody2D and player != currentPlayer:
			var camListEntryNode = camListEntry.instantiate();
			vHolder.add_child(camListEntryNode);
			camListEntryNode.setName(player.name);
			camListEntryNode.setCurrent(currentPlayer);
			camListEntryNode.setTarget(player);
