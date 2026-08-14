extends Node;

# driverEnter: Player/Idle.gd, Hud.gd, Empty.gd
# driverExit: Sinking.gd, InShip.gd
# reqCamList: InShip.gd, Player/Idle.gd, Hud.gd
# cameraSwitching: MainCamera.gd, Hud.gd, Player/Idle.gd, InShip.gd
# vehicleDestroying: Hud.gd, Skinking.gd 
# vehicleDestroyed: Hud.gd, Skinking.gd
# vehicalLowHp: Hud.gd, Sinking.gd
# playerIdle: Hud.gd, Idle.gd, MainCamera.gd
# cameraSwitching: mainCamera.gd, Player/Idle.gd, InShip.gd, Player/Disabled.gd, Driving.gd
# cameraSwitched: Player.gd, Hud.gd, mainCamera.gd
# toggleDebug: Tree, Rock, Bush

signal playerIdle(player: CharacterBody2D);
signal reqCamList(packet: Dictionary);
signal noPlayersLeft();
signal cameraSwitching(packet: Dictionary);
signal cameraSwitched(packet: Dictionary);
signal vehicleDestroying(packet: Dictionary);
signal vehicleDestroyed(packet: Dictionary);
signal reqPlayerSwitch(packet: Dictionary);
signal reqLinearSwitch(packet: Dictionary);
signal playerDead(packet: Dictionary);
signal vehicalLowHp(drive: CharacterBody2D);
signal driverEnter(packet: Dictionary);
signal driverExit(packet: Dictionary);
signal nonPlayerDead(packet: Dictionary);
signal toggleDebug(flag: bool);

# Variables 
var hud: CanvasLayer;
var mainCamera: Camera2D;
var playerDeadRef: Array[StringName] = [];

func _ready() -> void:
	# Setup Hud 
	hud = Lod.gameHud.instantiate();
	get_tree().current_scene.add_child(hud);

	# Setup Main Camera
	mainCamera = Lod.mainCamera.instantiate();
	get_tree().current_scene.add_child(mainCamera);

	# Signal 
	cameraSwitched.connect(postSwitchCheck);

	# Lambda signal
	playerDead.connect(func(packet: Dictionary):
		playerDeadRef.append(packet[&"name"]);
		print(playerDeadRef);
	)

func getHud() -> CanvasLayer:
	if (hud and is_instance_valid(hud)and not hud.is_queued_for_deletion()): return hud;
	else: return null;

func getMainCamera() -> Camera2D:
	if (is_instance_valid(mainCamera) and not hud.is_queued_for_deletion()): return mainCamera;
	else: return null;

func setCursor(c :Resource) -> void:
	Input.set_custom_mouse_cursor(c);

func removeCursor() -> void:
	setCursor(Lod.cursor);

func postSwitchCheck(packet) -> void:
	if packet[&"targetName"] == &"NULL" or packet[&"targetName"] in playerDeadRef:
		# Request switch 
		mainCamera = getMainCamera();
		# Camera Exist
		if mainCamera:
			# Random Switch 
			mainCamera.randomSwitch({
				&"name": &"NULL",
			})
			# Clear playerDeadRef
			playerDeadRef = [];
