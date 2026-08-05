extends CanvasLayer;

# Signals
signal reqCamList(player: Variant);

# Lazy Load
@onready var jstick: VirtualJoystick = $Toggle/VirtualJoystick;
@onready var boostBtn: Control = $Toggle/Boost;
@onready var fpsText: Label = $FPS
@onready var ship_ext: Control = $Toggle/ShipExt;
@onready var toggleHud: Control = $Toggle;
@onready var camSwitch: Control = $Toggle/CamSwitch

# Variables
var jevent:  Array[StringName];
enum Buttons {BOOST, CAM_SWITCH, SHIP_EXIT}
var camListNode: Control;

# Booleans
var isCamList = false;

func _ready() -> void:	
	# Connect Signal 
	reqCamList.connect(showCamList);
	
	# Joystick
	jevent = [
		jstick.action_up,
		jstick.action_down,
		jstick.action_left,
		jstick.action_right
	];
	jstick.visibility_mode = VirtualJoystick.VISIBILITY_WHEN_TOUCHED;
	# Debug Properties 
	ship_ext.process_mode = Node.PROCESS_MODE_DISABLED;
	ship_ext.visible = false;

func _process(_delta: float) -> void:
	processFps();

func processFps() -> void:
	fpsText.text = "FPS:  "+ str(Engine.get_frames_per_second());

func disableBtn(btn: Buttons) -> void:
	match btn:
		Buttons.BOOST:
			boostBtn.process_mode = Node.PROCESS_MODE_DISABLED;
			boostBtn.visible = false;
		Buttons.SHIP_EXIT:
			ship_ext.process_mode = Node.PROCESS_MODE_DISABLED;
			ship_ext.visible = false;
		Buttons.CAM_SWITCH:
			camSwitch.process_mode = Node.PROCESS_MODE_DISABLED;
			camSwitch.visible = false;

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

func enableBtn(btn: Buttons) -> void:
	match btn:
		Buttons.BOOST:
			boostBtn.process_mode = Node.PROCESS_MODE_INHERIT;
			boostBtn.visible = true;
		Buttons.SHIP_EXIT:
			ship_ext.process_mode = Node.PROCESS_MODE_INHERIT;
			ship_ext.visible = true;
		Buttons.CAM_SWITCH:
			camSwitch.process_mode = Node.PROCESS_MODE_INHERIT;
			camSwitch.visible = true;

func deadScreen(_show: bool) -> void:
	# TODO: Make Dead Screen;
	pass;

func setCamList(flag: bool):
	if not flag:
		isCamList = false;
		if camListNode: camListNode.queue_free();
	else:
		isCamList = true;

func showCamList(player: Variant):
	# Toggle Cam List
	if not isCamList:
		# Set Flag
		setCamList(true);
		# Setup the CamList
		camListNode = Lod.camList.instantiate() as Control;
		camSwitch.add_child(camListNode);
		# Start feaching players
		camListNode.fetch(player);
	else:
		setCamList(false);
