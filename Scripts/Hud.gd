extends CanvasLayer;

# Lazy Load
@onready var jstick: VirtualJoystick = $Toggle/VirtualJoystick;
@onready var properties: Panel = $Toggle/Properties;
@onready var hideBtn: Button = $Toggle/Hide;
@onready var boostBtn: Control = $Toggle/Boost;

# Properties
@onready var jsize: LineEdit = $Toggle/Properties/Scroll/VBox/Prop/Val;
@onready var jtip: LineEdit = $Toggle/Properties/Scroll/VBox/Prop2/Val;
@onready var jhidden: CheckButton = $Toggle/Properties/Scroll/VBox/Prop5/Button;
@onready var logCenter: RichTextLabel = $Toggle/Hide/Log;
@onready var ship_ext: Control = $Toggle/ShipExt;
@onready var toggleHud: Control = $Toggle;


# Constants
const LOG_PATH: String = "user://logs/godot.log";

# Variables
var filePos: int = 0;
var logTimer: Timer = Timer.new();
var jevent:  Array[StringName];

func _ready() -> void:	
	# Log Setup
	print("Log Found: " + LOG_PATH);
	logTimer.wait_time = 0.2;
	logTimer.autostart = true;
	logTimer.timeout.connect(checkLog);
	self.add_child(logTimer);
	# Joystick
	jevent = [
		jstick.action_up,
		jstick.action_down,
		jstick.action_left,
		jstick.action_right
	];
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

func disableBtn(btn: String) -> void:
	match btn:
		"Boost":
			boostBtn.process_mode = Node.PROCESS_MODE_DISABLED;
			boostBtn.visible = false;

func disableSelf(yes: bool) -> void:
	if (yes):
		# Hide the hud
		toggleHud.visible = false;
		# Stop Joystick Events
		for event in jevent:
			if event: Input.action_release(event);
		# Clear the touch even
		var release = InputEventScreenTouch.new()
		release.pressed = false
		release.index = 0
		# Wait for engine
		Input.parse_input_event(release)
		await get_tree().process_frame
		# Stop Processing Hud
		toggleHud.process_mode = Node.PROCESS_MODE_DISABLED;
	else:
		# Start Processing Hud
		toggleHud.process_mode = Node.PROCESS_MODE_INHERIT;
		toggleHud.visible = true;

func enableBtn(btn: String) -> void:
	match btn:
		"Boost":
			boostBtn.process_mode = Node.PROCESS_MODE_INHERIT;
			boostBtn.visible = true;

func deadScreen(_show: bool) -> void:
	# TODO: Make Dead Screen;
	pass;

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

func handleWaterShaders(index: int) -> void:
	var water = Manager.getWater();
	var parallex = water.get_child(0);
	
	# Setup Water
	for texture in parallex.get_children():
		texture.visible = false;
		texture.process_mode = Node.PROCESS_MODE_DISABLED;
		
	# Temp setup 
	var target = parallex.get_child(index);
	target.process_mode = Node.PROCESS_MODE_INHERIT;
	target.visible = true;
	
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
