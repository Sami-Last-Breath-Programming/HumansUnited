extends Node;

# Global Signlas
signal reqPlayerSwitch(player: Variant);

# Global Lazy Load
const SwitchCameraScene: PackedScene = preload("res://Scenes/SwitchCamera.tscn");
const gameHud: PackedScene = preload("res://Scenes/Hud.tscn");

# Variables 
var hud: CanvasLayer;

func _ready() -> void:
	# Connect Signlas
	reqPlayerSwitch.connect(initSwitchCamera);
	# Setup Hud 
	hud = gameHud.instantiate();
	get_tree().current_scene.add_child(hud);

func getHud() -> CanvasLayer:
	if (hud): return hud;
	else: return null;
	
func initSwitchCamera(player: Variant):
	print("Switch Request from: ", reqPlayerSwitch);
	if (SwitchCameraScene):
		# Start Switching 
		var switchCamera = SwitchCameraScene.instantiate();
		switchCamera.player = player;
		get_tree().current_scene.add_child(switchCamera);
