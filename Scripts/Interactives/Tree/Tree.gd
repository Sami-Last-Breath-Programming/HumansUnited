extends StaticBody2D;

# Lazy Load
@onready var debug: Label = $Debug;

func _ready() -> void:
	Manager.toggleDebug.connect(func(flag: bool):
		debug.visible = flag;	
	)

func doAction(packet: Dictionary) -> void:
	if packet[&"id"] == self.get_instance_id():
		debug.text = "Doing Action";
	else:
		var cached: String = debug.text;
		debug.text = "Not My Player...";
		await get_tree().create_timer(2).timeout;
		debug.text = cached;
	
func stopAction() -> void:
	debug.text = "Doing Nothing";

