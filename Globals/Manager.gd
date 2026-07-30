extends Node;

# Global Signlas
signal reqPlayerSwitch(player: Variant);

# Global Lazy Load
const SwitchCameraScene: PackedScene = preload("res://Scenes/SwitchCamera.tscn");

func _ready() -> void:
	# Connect Signlas
	reqPlayerSwitch.connect(initSwitchCamera);
	
func initSwitchCamera(player: Variant):
	print("reached!")
	if (SwitchCameraScene):
		# Start Switching 
		var switchCamera = SwitchCameraScene.instantiate();
		switchCamera.player = player;
		get_tree().current_scene.add_child(switchCamera);
