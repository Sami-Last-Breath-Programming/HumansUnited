extends CanvasLayer;

# Lazy Load
@onready var jstick: VirtualJoystick = $VirtualJoystick;
@onready var properties: Panel = $Properties;
@onready var hideBtn: Button = $Hide;

# Properties
@onready var jsize: LineEdit = $Properties/Scroll/VBox/Prop/Val;
@onready var jtip: LineEdit = $Properties/Scroll/VBox/Prop2/Val;
@onready var jhidden: CheckButton = $Properties/Scroll/VBox/Prop5/Button;
@onready var logCenter: RichTextLabel = $Hide/Log;
@onready var ship_ext: Control = $ShipExt

# Constants
const LOG_PATH: String = "user://logs/godot.log";

# Variables
var filePos: int = 0;
var logTimer: Timer = Timer.new();

func _ready() -> void:	
	# Log Setup
	print("Log Found: " + LOG_PATH);
	logTimer.wait_time = 0.2;
	logTimer.autostart = true;
	logTimer.timeout.connect(checkLog);
	self.add_child(logTimer);
	# Joystick
	jstick.visibility_mode = VirtualJoystick.VISIBILITY_WHEN_TOUCHED;
	jhidden.button_pressed = true;
	# Debug Properties 
	ship_ext.process_mode = Node.PROCESS_MODE_DISABLED;
	hideBtn.process_mode = Node.PROCESS_MODE_DISABLED;
	properties.process_mode = Node.PROCESS_MODE_DISABLED;
	ship_ext.visible = false;
	hideBtn.visible = false;
	properties.visible = false;

func checkLog() -> void:
	# Check for file 
	var logFile = FileAccess.open(LOG_PATH, FileAccess.READ);
	# Handle No file 
	if (logFile == null): return;
	# Get the file Length
	var fileLen = logFile.get_length();
	# Go to the last file line
	logFile.seek(filePos);
	# Check for new logs
	if (fileLen <= filePos): 
		logFile.close();
		return;
	# Read the new log 
	var logText = logFile.get_buffer(fileLen - filePos).get_string_from_utf8();
	# Update last file position
	filePos = logFile.get_position();
	logFile.close();
	# process Lines of logs
	var lines := logText.split("\n", false);
	# Udate log center
	for line in lines:
		logCenter.text = logCenter.text + "\n\t" + line + "\t";

func showShipExit() -> void:
	ship_ext.process_mode = Node.PROCESS_MODE_INHERIT;
	ship_ext.visible = true;

func hideShipExit() -> void:
	ship_ext.process_mode = Node.PROCESS_MODE_DISABLED;
	ship_ext.visible = false;

func showProperties() -> void:
	hideBtn.process_mode = Node.PROCESS_MODE_INHERIT;
	properties.process_mode = Node.PROCESS_MODE_INHERIT;
	hideBtn.visible = true;
	properties.visible = true;

func hideProperties() -> void:
	hideBtn.process_mode = Node.PROCESS_MODE_DISABLED;
	properties.process_mode = Node.PROCESS_MODE_DISABLED;
	hideBtn.visible = false;
	properties.visible = false;

func joysticSizeUpdate() -> void:
	if jsize.text != "":
		jstick.joystick_size = jsize.text.to_float();
		jsize.placeholder_text = "Value: " + jsize.text;
		jsize.text = "";

func joysticTipUpdate() -> void:
	if jsize.text != "":
		jstick.tip_size = jtip.text.to_float();
		jtip.placeholder_text = "Value: " + jtip.text;
		jtip.text = "";

func joysticFixedUpdate() -> void:
	jstick.joystick_mode = VirtualJoystick.JOYSTICK_FIXED;

func joysticDynamicUpdate() -> void:
	jstick.joystick_mode = VirtualJoystick.JOYSTICK_DYNAMIC;

func joysticVisibilityUpdate(on: bool) -> void:
	if on:
		jstick.visibility_mode = VirtualJoystick.VISIBILITY_WHEN_TOUCHED;
	else:
		jstick.visibility_mode = VirtualJoystick.VISIBILITY_ALWAYS;
