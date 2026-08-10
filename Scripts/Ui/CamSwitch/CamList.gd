extends Node

#Lazy Load 
@onready var camListEntry: PackedScene = preload("res://Scenes/UI/CamListEntry.tscn");
@onready var vHolder: VBoxContainer = $BG/Scroll/Vbox;
@onready var showAnim: ProtonControlAnimation = $Show;
@onready var hideAnim: ProtonControlAnimation = $Hide;

# Booleans 
var onWay: bool = false;

func fetch(packet: Dictionary) -> void:
	# Start Animation
	if not self.visible: self.visible = true;
	onWay = true;
	showAnim.start();
	# Find all players 
	var players: Array[Node] = get_tree().get_nodes_in_group("Player");
	# Init the CamList Entry
	for player in players:
		if player is CharacterBody2D:
			# Handle Current player
			if player.name == packet[&"name"]: continue;
			
			# Setup Button
			var camListEntryNode = camListEntry.instantiate();
			vHolder.add_child(camListEntryNode);
			camListEntryNode.setName(player.name);
			camListEntryNode.setLastPlayerName(packet[&"name"]);
			camListEntryNode.setTarget(player);
			camListEntryNode.playStart();

func hideSelf(flag: bool):
	# Disable Processing 
	for button in vHolder.get_children():
		button.process_mode = Node.PROCESS_MODE_DISABLED;
	# Handle Anim
	if flag: 
		hideAnim.start();
		onWay = true;
	else: handleHide();

func handleHide() -> void:
	onWay = false;
	# Hide visibality
	self.visible = false;
	# Remove players btn
	for button in vHolder.get_children():
		button.queue_free();

func handleShow() -> void:
	onWay = false;
