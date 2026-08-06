extends Node;

# Global Signlas
signal reqPlayerSwitch(player: Variant);

# Variables 
var hud: CanvasLayer;
var water: Node2D;

func _ready() -> void:
	# Connect Signlas
	reqPlayerSwitch.connect(initSwitchCamera);
	# Setup Water
	water = Lod.gameWater.instantiate();
	get_tree().current_scene.add_child(water);
	# Setup Hud 
	hud = Lod.gameHud.instantiate();
	get_tree().current_scene.add_child(hud);

func getHud() -> CanvasLayer:
	if (hud): return hud;
	else: return null;

func getWater() -> Node2D:
	if (water): return water;
	else : return null;	

func setCursor(c :Resource) -> void:
	Input.set_custom_mouse_cursor(c);

func removeCursor() -> void:
	setCursor(Lod.cursor);

func initSwitchCamera(player: Variant):
	print("Switch Request from: ", reqPlayerSwitch);
	if (Lod.SwitchCameraScene):
		# Start Switching 
		var switchCamera = Lod.SwitchCameraScene.instantiate();
		get_tree().current_scene.add_child(switchCamera);
		switchCamera.randomSwitch(player);
