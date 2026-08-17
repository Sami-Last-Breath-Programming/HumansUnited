extends StaticBody2D;

# Lazy Load
@onready var debug: Label = $Debug;

func _ready() -> void:
	# Set Debug flase
	debug.visible = false;
	
	# Connect Signal
	Manager.toggleDebug.connect(func(flag: bool):
		debug.visible = flag;	
	)

func doAction(packet: Dictionary) -> void:
	if packet[&"id"] == self.get_instance_id():
		debug.text = "Doing Action";
	
func stopAction() -> void:
	debug.text = "Doing Nothing";

