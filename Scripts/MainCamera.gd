extends Camera2D;

# Signals
signal playerVehicleActive(packet: Dictionary);

# Constants
const CHECK_TIME: float = 4.0;
const MAX_CAMERA_SWITCH_SPEED: float = 400.0;

# Variables
var switchAnim: Tween;
var closestPlayer: CharacterBody2D;
var closestDistant: float = INF;
var camTimer: Timer = Timer.new();

# Booleans 
var isFirstReq: bool = true;
var isSwiching: bool = false;

func _ready() -> void:
	# Connect Signals
	Manager.playerIdle.connect(followPlayer);
	Manager.reqLinearSwitch.connect(switch);
	self.playerVehicleActive.connect(followVehicle);
	Manager.reqPlayerSwitch.connect(randomSwitch);
	Manager.driverExit.connect(postExitVehicleSetup);
	
	# lamda options
	Manager.playerDead.connect(func(packet: Dictionary):
		if (self.get_parent().name == packet[&"name"]):
			self.reparent(get_tree().current_scene);
	);

	# Set up timer 
	self.add_child(camTimer);
	camTimer.one_shot = true;
	camTimer.timeout.connect(handleRoot);
	
func followPlayer(player: CharacterBody2D) -> void:
	# Wait for others
	await get_tree().process_frame;
	
	# Handle only parenting 
	if not isFirstReq: 
		self.reparent(player);
		self.global_position = player.global_position;

	else:
		# Setup camera
		self.global_position = player.global_position;
		self.reparent(player);
		self.zoom = Global.defaultCameraZoom;
		# Wait
		await get_tree().create_timer(0.5).timeout;

	# Zoom Setup For player
	var tween = create_tween();
	tween.tween_property(self, "zoom", Vector2(2.4, 2.4), 1);
	isFirstReq= false;

func followVehicle(packet: Dictionary) -> void:
	var vehicle = instance_from_id(packet[&"vehicleId"]) as CharacterBody2D;
	# Vehicle Exist
	if vehicle:
		self.reparent(vehicle);
		self.global_position = packet[&"vehiclePos"];
		
		# Wait
		await get_tree().create_timer(0.2).timeout;

		# Zoom Setup For player
		var tween = create_tween();
		tween.tween_property(self, "zoom", Vector2(1.6, 1.6), 1);

		tween.finished.connect(func():
			# Enable Camera Smoothing 
			self.position_smoothing_enabled = true;
			self.rotation_smoothing_enabled = true;	
		);

func postExitVehicleSetup(packet: Dictionary) -> void:
	# Setup Zoom 
	self.reparent(get_tree().current_scene);
	var driverPos = packet[&"driverPos"];
	self.global_position = driverPos;
	self.position_smoothing_enabled = false;
	self.rotation_smoothing_enabled = false;	
	self.zoom = Vector2(1.6, 1.6);
	
	# Disable Camera Smoothing 
	self.position_smoothing_enabled = false;
	self.rotation_smoothing_enabled = false;	

	# Zoom towards driver
	var tween = create_tween();
	tween.tween_property(self, "zoom", packet[&"cameraZoom"], 1);

func switch(packet: Dictionary) -> void:	
	# Signal to Manager
	Manager.cameraSwitching.emit(packet);
	
	# Set target
	closestPlayer = checkPlayer(packet[&"targetPlayer"]);
	if not closestPlayer: 
		findClosestPlayer(packet[&"lastPlayerName"]);

	# Set Signal in closest player
	if checkPlayer(closestPlayer):
		if (not Manager.cameraSwitched.is_connected(closestPlayer.handleSwitch)):
			Manager.cameraSwitched.connect(closestPlayer.handleSwitch);
	
	# Play switch animation
	playAnim({
		&"targetPlayer": closestPlayer,
		&"targetName": closestPlayer.name if checkPlayer(closestPlayer) else &"NULL",
		&"lastPlayerName": packet[&"lastPlayerName"]
	});

func randomSwitch(packet: Dictionary) -> void:
	# Signal to Manager
	Manager.cameraSwitching.emit({&"lastPlayerName": packet[&"name"]});
	
	# Find the closest player
	findClosestPlayer(packet[&"name"]);
	
	# Set Signal in closest player
	if checkPlayer(closestPlayer):
		if (not Manager.cameraSwitched.is_connected(closestPlayer.handleSwitch)):
			Manager.cameraSwitched.connect(closestPlayer.handleSwitch);

	# Play and Free
	playAnim({
		&"targetPlayer": checkPlayer(closestPlayer),
		&"targetName": closestPlayer.name if checkPlayer(closestPlayer) else &"NULL",
		&"lastPlayerName": packet[&"name"]
	});

func checkPlayer(p: Variant) ->  CharacterBody2D:
	if (is_instance_valid(p) and not p.is_queued_for_deletion()): return p if p is CharacterBody2D else null;
	else: return null;

func findClosestPlayer(lastPlayer: StringName) -> void:
	# Get All player nodes
	var players: Array[Node] = get_tree().get_nodes_in_group("Player");
	# Handle only one player
	if players.size() == 1:
		closestPlayer = players[0] if players[0].name != lastPlayer else null;
		
	else:
		# Loop on Array
		for player in players:		
			player = checkPlayer(player);
			# If closest player exist
			if player:
				# Handle Self 			
				if player.name == lastPlayer: continue;
				# Get the Distance of Npc
				var npcDis = self.global_position.distance_squared_to(player.global_position);
				# Store the smallest distance and player
				if (npcDis <= closestDistant):
					closestDistant = npcDis
					closestPlayer = player;
	# Reset closest distance
	closestDistant = INF;	

func playAnim(packet: Dictionary) -> void:
	# Handle all players dead
	closestPlayer = checkPlayer(closestPlayer);
	print(closestPlayer.name);
	if not closestPlayer:
		# Signal To Manager
		Manager.noPlayersLeft.emit();
		return;

	# Calculate distance 
	var dis: float = self.global_position.distance_to(closestPlayer.global_position);
	var switchTime: float = dis / MAX_CAMERA_SWITCH_SPEED;
	
	# Enable Camera Smoothing 
	self.position_smoothing_enabled = true;
	self.rotation_smoothing_enabled = true;

	# Create a tween
	switchAnim = create_tween();
	switchAnim.tween_property(self, "zoom", Global.defaultCameraZoom, 0.5);
	switchAnim.tween_property(self, "global_position", closestPlayer.global_position, switchTime);
	
	# Wait for animation finised
	switchAnim.finished.connect(func ():
		await get_tree().create_timer(0.8).timeout;
		
		# Disable Camera Smoothing 
		self.position_smoothing_enabled = false;
		self.rotation_smoothing_enabled = false;
		
		# Signal to Manager
		Manager.cameraSwitched.emit(packet);
		closestPlayer = null;

		# Start camTimer
		camTimer.start(CHECK_TIME);
	);

func handleRoot() -> void:
	if self.get_parent().name == &"World":
		# Random Switch 
		randomSwitch({
			&"name": &"NULL",
		})

func stopTimer() -> void:
	if not camTimer.is_stopped():
		camTimer.stop();
