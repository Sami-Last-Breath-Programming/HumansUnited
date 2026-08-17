extends CanvasLayer;

# reqHandBtn() -> {&"id": int, playerId: int, &"show": bool}

# Signals
signal reqHandBtn(packet: Dictionary);
signal handBthHidden(packet: Dictionary);

# Lazy Load
@onready var jstick: VirtualJoystick = $Toggle/VirtualJoystick;
@onready var boostBtn: Control = $Toggle/Boost;
@onready var fpsText: Label = $FPS
@onready var vehicalExt: Control = $Toggle/VehicleExt;
@onready var toggleHud: Control = $Toggle;
@onready var camSwitch: Control = $Toggle/CamSwitch
@onready var handBtn: TextureButton = $Toggle/HandBtn;

# Constants
const HIDE_TOUCH_BUTTON_POS: Vector2 = Vector2(6000, 0);

# Variables
var inventroy: Button = null;
var camListNode: Control;
var lastHandPacket: Dictionary = {};
var jevent:  Array[StringName];
var touchBtnPos: Dictionary;
enum Buttons {BOOST, CAM_SWITCH, VEHICLE_EXIT, HAND}

# Booleans
var isCamList = false;
var isDebug = false;

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
		disableSelf(false);
		# Show touch btns 
		vehicalExt.global_position = touchBtnPos[&"vehicalExt"];
		boostBtn.global_position = touchBtnPos[&"boostBtn"];
	);
	Manager.vehicalLowHp.connect(func(driver: CharacterBody2D):
		if driver: disableBtn(Buttons.BOOST);
	);
	reqHandBtn.connect(func(packet: Dictionary):
		# Caller exist
		var ref: Variant = instance_from_id(packet.get(&"id", -1));
		if ref:
			# Check for flag
			if packet[&"show"]: 
				# Enable button
				enableBtn(Buttons.HAND);
				lastHandPacket = packet;
			else : 
				# Disable button
				disableBtn(Buttons.HAND);

				# Send Stop 
				if ref.has_method("stopAction"):
					ref.stopAction();
	);
	handBtn.pressed.connect(func():
		# If not packet 
		if lastHandPacket.is_empty(): return;
		
		# Caller exist
		var ref: Variant = instance_from_id(lastHandPacket.get(&"id", null));
		if ref and ref.has_method("doAction"):
			ref.doAction(lastHandPacket);

		# Send the siganl to weapon if exist 
		var id: int = lastHandPacket.get(&"playerId", -1);
		# Handle null ref
		if id != -1:	
			var player: CharacterBody2D = instance_from_id(id);
			if player.has_method("getWeapon"):
				var weapon = player.getWeapon();
				if weapon and weapon.has_method("doAction"): 
					weapon.doAction();
	)
	
	# Joystick
	jevent = [
		jstick.action_up,
		jstick.action_down,
		jstick.action_left,
		jstick.action_right
	];
	jstick.visibility_mode = VirtualJoystick.VISIBILITY_WHEN_TOUCHED;
	
	# Disable Properties 
	vehicalExt.process_mode = Node.PROCESS_MODE_DISABLED;
	handBtn.disabled = true;
	vehicalExt.visible = false;
	handBtn.visible = false;

	# Cache touch buttons pos
	touchBtnPos[&"vehicalExt"] = vehicalExt.global_position;
	touchBtnPos[&"boostBtn"] = boostBtn.global_position;

func _process(_delta: float) -> void:
	processFps();

func processFps() -> void:
	fpsText.text = "FPS:  "+ str(Engine.get_frames_per_second());

func disableBtn(btn: Buttons) -> void:
	match btn:
		Buttons.BOOST:
			boostBtn.process_mode = Node.PROCESS_MODE_DISABLED;
			boostBtn.visible = false;
		Buttons.HAND:
			if not handBtn.disabled: handBtn.disabled = true;
			if handBtn.visible: handBtn.visible = false;
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
		Buttons.HAND:
			if handBtn.disabled: handBtn.disabled = false;
			if not handBtn.visible: handBtn.visible = true;
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
		vehicalExt.global_position = HIDE_TOUCH_BUTTON_POS;
		boostBtn.global_position = HIDE_TOUCH_BUTTON_POS;
		
		# Setup the CamList
		if camListNode and is_instance_valid(camListNode):
			camListNode.fetch(packet);
		else:
			camListNode = Lod.camList.instantiate() as Control;
			camSwitch.add_child(camListNode);
			camListNode.fetch(packet);
	else:
		# Show touch btns 
		vehicalExt.global_position = touchBtnPos[&"vehicalExt"];
		boostBtn.global_position = touchBtnPos[&"boostBtn"];
		setCamList(false, true);

func openInventroy() -> void:
	# Init inventory
	if not inventroy or not is_instance_valid(inventroy):
		inventroy = Lod.inventroy.instantiate() as Button;
		toggleHud.add_child(inventroy);
		inventroy.openInventroy();
	else:
		inventroy.process_mode = Node.PROCESS_MODE_INHERIT;
		inventroy.openInventroy();

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

func handleDebugToggle() -> void:
	if not isDebug:
		isDebug = true;
		Manager.toggleDebug.emit(isDebug);
	else:
		isDebug = false;
		Manager.toggleDebug.emit(isDebug);
