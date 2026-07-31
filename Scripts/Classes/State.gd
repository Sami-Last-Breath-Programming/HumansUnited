# State BluePrint Class
class_name State;
extends Node;

var id: int = -1;
var parent: Node;
var stateManager: Node;

func _ready() -> void:
	# Wait for owner
	await owner.ready;
	
func Entry() -> void: pass;

func Exit() -> void: pass;

func Update(_d: float) -> void: pass;

func PhysicsUpdate(_d: float) -> void: pass;

func HandleInput(_e: InputEvent) -> void: pass;
