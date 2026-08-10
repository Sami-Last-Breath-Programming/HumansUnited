extends VBoxContainer

# Lazy Load
@onready var Name: Label = $Base/Button/Text
@onready var SlideIn: ProtonControlAnimation = $Base/Button/SlideIn

# Variables
var lastPlayerName: StringName
var targetPlayer: CharacterBody2D;

func onFocus():
	Manager.setCursor(Lod.clickedCursor);

func notFocus():
	Manager.removeCursor();

func setName(pName: String):
	Name.text = pName;

func setLastPlayerName(lpName: StringName):
	lastPlayerName = lpName;

func setTarget(target: CharacterBody2D = null):
	if target and is_instance_valid(target): targetPlayer = target;
	else: targetPlayer = null;

func handleSwitch() -> void:
	var packet: Dictionary = {
		&"lastPlayerName": lastPlayerName,
		&"targetPlayer": targetPlayer,
	}
	Manager.reqLinearSwitch.emit(packet);

func playStart() -> void:
	SlideIn.start();
