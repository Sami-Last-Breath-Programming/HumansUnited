extends VBoxContainer

# Lazy Load
@onready var Name: Label = $Base/Button/Text
@onready var SlideIn: ProtonControlAnimation = $Base/Button/SlideIn

# Variables
var player: CharacterBody2D;
var targetPlayer: CharacterBody2D;

func onFocus():
	Manager.setCursor(Lod.clickedCursor);

func notFocus():
	Manager.removeCursor();

func setName(pName: String):
	Name.text = pName;

func setCurrent(current: CharacterBody2D = null):
	if current: player = current;

func setTarget(target: CharacterBody2D = null):
	if target: targetPlayer = target;

func handleSwitch() -> void:
	var switchCamera = Lod.SwitchCameraScene.instantiate();
	get_tree().current_scene.add_child(switchCamera);
	switchCamera.switch(player, targetPlayer);

func playStart() -> void:
	SlideIn.start();
