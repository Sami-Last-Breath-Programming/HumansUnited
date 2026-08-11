extends CanvasLayer;

# Lazy Load
@onready var jstick: VirtualJoystick = $Toggle/VirtualJoystick;
@onready var boostBtn: Control = $Toggle/Boost;
@onready var fpsText: Label = $FPS
@onready var vehicalExt: Control = $Toggle/VehicleExt;
@onready var toggleHud: Control = $Toggle;
@onready var camSwitch: Control = $Toggle/CamSwitch

# Variables
var camListNode: Control;
var jevent:  Array[StringName];
enum Buttons {BOOST, CAM_SWITCH, VEHICLE_EXIT}

# Booleans
var isCamList = false;

func _ready() -> void:	
	# Connect Signal 
	Manager.reqCamList.connect(showCamList);
	Manager.noPlayersLeft.connect(deadScreen);
	Manager.driverEnter.connect(showDriverHud);
	Manager.driverExit.connect(hideDriverHud);
	
	# Lamda Signlas;
	Manager.playerIdle.connect(func(_drive: CharacterBody2D):
		# Disable Vehicle controls 
		hideDriverHud();
		# Enable player controls
		showPlayerHud();
	);
	
	Manager.vehicleDestroying.connect(func(packet: Dictionary):
		if packet[&"driver"]: 
			await get_tree().create_timer(0.1).timeout;
			disableSelf(true);
	);
	
	Manager.vehicleDestroyed.connect(func(packet: Dictionary):
		if packet[&"driver"]: disableSelf(false);	
	)

	Manager.cameraSwitching.connect(func(_packet: Dictionary):
		setCamList(false, true);
		# showCamList();
		await get_tree().create_timer(0.6).timeout;
		disableSelf(true);
	);
	Manager.cameraSwitched.connect(func(_packet: Dictionary): 
		await get_tree().create_timer(0.4).timeout;	
		disableSelf(false)
	);
	Manager.vehicalLowHp.connect(func(driver: CharacterBody2D):
		if driver: disableBtn(Buttons.BOOST);
	);
	
	# Joystick
	jevent = [
		jstick.action_up,
		jstick.action_down,
		jstick.action_left,
		jstick.action_right
	];
	jstick.visibility_mode = VirtualJoystick.VISIBILITY_WHEN_TOUCHED;
	# Debug Properties 
	vehicalExt.process_mode = Node.PROCESS_MODE_DISABLED;
	vehicalExt.visible = false;

func _process(_delta: float) -> void:
	processFps();

func processFps() -> void:
	fpsText.text = "FPS:  "+ str(Engine.get_frames_per_second());

func disableBtn(btn: Buttons) -> void:
	match btn:
		Buttons.BOOST:
			boostBtn.process_mode = Node.PROCESS_MODE_DISABLED;
			boostBtn.visible = false;
		Buttons.VEHICLE_EXIT:
			vehicalExt.process_mode = Node.PROCESS_MODE_DISABLED;
			vehicalExt.visible = false;
		Buttons.CAM_SWITCH:
			camSwitch.process_mode = Node.PROCESS_MODE_DISABLED;
			camSwitch.visible = false;

func disableSelf(yes: bool = true) -> void:
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
		Buttons.VEHICLE_EXIT:
			vehicalExt.process_mode = Node.PROCESS_MODE_INHERIT;
			vehicalExt.visible = true;
		Buttons.CAM_SWITCH:
			camSwitch.process_mode = Node.PROCESS_MODE_INHERIT;
			camSwitch.visible = true;

func deadScreen() -> void:
	# TODO: Make Dead Screen;
	# Stop Camera timer 
	var mainCamera = Manager.getMainCamera();
	if mainCamera:
		mainCamera.stopTimer();

func setCamList(flag: bool, anim: bool):
	if not flag:
		isCamList = false;
		if camListNode and not camListNode.onWay: 
			camListNode.hideSelf(anim);
	else:
		isCamList = true;

func showCamList(packet: Dictionary):
	# Hadnle Toggle
	if camListNode and camListNode.onWay:
		return
	# Toggle Cam List
	if not isCamList:
		# Set Flag
		setCamList(true, false);
		
		# Hide touch btns 
		disableBtn(Buttons.BOOST);
		disableBtn(Buttons.VEHICLE_EXIT);
		
		# Setup the CamList
		if camListNode and is_instance_valid(camListNode):
			camListNode.fetch(packet);
		else:
			camListNode = Lod.camList.instantiate() as Control;
			camSwitch.add_child(camListNode);
			camListNode.fetch(packet);
	else:
		# Show touch btns 
		enableBtn(Buttons.BOOST);
		enableBtn(Buttons.VEHICLE_EXIT);
		setCamList(false, true);

func onFocus():
	Manager.setCursor(Lod.clickedCursor);

func notFocus():
	Manager.removeCursor();

func showPlayerHud() -> void:
	enableBtn(Buttons.BOOST);
	enableBtn(Buttons.CAM_SWITCH);

func showDriverHud(packet: Dictionary) -> void:
	match packet[&"vehicle"]:
		&"Ship":
			enableBtn(Buttons.VEHICLE_EXIT);
			if not packet[&"vehicleDamaged"]: enableBtn(Buttons.BOOST);
			else: disableBtn(Buttons.BOOST);	

func hideDriverHud(packet: Dictionary = {&"vehicle": null}) -> void:
	match packet[&"vehicle"]:
		&"Ship":
			disableBtn(Buttons.VEHICLE_EXIT);
		null:
			disableBtn(Buttons.VEHICLE_EXIT);  # Disable all vehicles hud 
