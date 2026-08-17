extends CharacterBody2D;

enum SkinType {SKIN, BOAT}

# Lazy Load 
@onready var dust 			:= $Dust;
@onready var texture 		:= $Texture;
@onready var outline 		:= $Texture/Outline;
@onready var healthBar 		:= $Progress;
@onready var collider 		:= $Collision;
@onready var stateManager 	:= $StateManager;
@onready var animManager 	:= $AnimManager;
@onready var playerData 	:= PlayerData.new();
@onready var playerName: RichTextLabel = $Hbox/Name
@onready var weaponHolder: Marker2D = $Weapon;

# Exported
@export var playerHealth: 		float;
@export var currentPlayerSkin: 	int;

# Variables
var lasDir: 			Vector2			= Vector2(0, 0);
var coolDownTime: 		float 			= 0.5;
var healthBarTime: 		float 			= 2.4;
var vehicle: 			CharacterBody2D = null;
var weapon:				Node2D		= null;
var playerBoatTexture: 	SpriteFrames 	= null;
var playerSkinTexture: 	SpriteFrames 	= null;
var playerSkinCollider: Resource 		= null;
var playerBoatCollider: Resource 		= null;
var result: 			Array 			= [null];
var coolDownTimer: 		Timer 			= Timer.new();
var hurtTimer:			Timer           = Timer.new();
var healthBarTimer: 	Timer 			= Timer.new();
var isEntredWaterTimer: Timer 			= Timer.new();
var outlineTimer:		Timer			= Timer.new();

# Setup Meta Data
var metaData:			Dictionary      = {
	&"id": null,
	&"state" : null,
	&"vehicleId" : null,
	&"vehicleType": null,
	&"inVehicle": false,
	&"isSwiching": false,
};

# Booelans
var toset:		bool = false;
var isCooldown: bool = false;

func _ready() -> void:
	# Set the Default Player Skin
	setSkin(currentPlayerSkin);
	setPlayerProperties();
	
	# Set id 
	metaData[&"id"] = self.get_instance_id();

	# Reference Weapon 
	weapon = weaponHolder.get_child(0);;

	# Init State Manager
	stateManager.init();
	
	# Set Health Bar
	healthBar.visible = false;
	healthBar.value = playerHealth;
	healthBar.max_value = playerHealth;
	
	# Timers Setup
	self.add_child(coolDownTimer);
	self.add_child(healthBarTimer);
	self.add_child(hurtTimer);
	self.add_child(outlineTimer);
	self.add_child(isEntredWaterTimer);
	hurtTimer.one_shot = true;
	coolDownTimer.one_shot = true;
	healthBarTimer.one_shot = true;
	isEntredWaterTimer.one_shot = true;
	
	# Timer timeout connect
	outlineTimer.timeout.connect(showWeaponOutline);
	hurtTimer.timeout.connect(func():
		handleAnim();
	)	
	healthBarTimer.timeout.connect(func():
		healthBar.visible = false;
		playerName.visible = true;
	);

func _process(_delta: float) -> void:
	# Process skin 
	processSkin();

func _physics_process(_delta: float) -> void:
	# Store last Direction
	var input = Input.get_vector(
		"Left", "Right", "Up", 
		"Down"
	);
	if (input != Vector2.ZERO):
		# Store last direction
		lasDir = input; 

func setSkin(index: int) -> void:
	# Set the skin index
	toset = true;
	currentPlayerSkin = index;
	# Request Resource Load
	for res in playerData.skins[currentPlayerSkin]:
		if res is String:
			Lod.req(res);
	
func setPlayerProperties() -> void:
	# Set Name 	
	playerName.text = self.name; 
	setNameColor("#f0f0f0");

	if not playerHealth: 		playerHealth = Global.defaultPlayerHeath;
	if not currentPlayerSkin: 	currentPlayerSkin = Global.defaultPlayerSkin;

func getSkin(index: int) -> String:
	return playerData.skins[currentPlayerSkin][index];

func processOutline() -> void:
	outline.sprite_frames = texture.sprite_frames;

func processSkin() -> void:
	# Check flag
	if not toset: return;
	
	# Get status
	var skin_s = Lod.stat(getSkin(0), result);
	var boat_skin_s = Lod.stat(getSkin(1), result);
	
	# Check if both ready
	if (skin_s == Lod.Stat.LOADED and boat_skin_s == Lod.Stat.LOADED):
		playerSkinTexture 		= Lod.grep(getSkin(0));
		playerBoatTexture 		= Lod.grep(getSkin(1));
		playerSkinCollider 		= Lod.grep(getSkin(2));
		playerBoatCollider 		= Lod.grep(getSkin(3));
		setPlayerSkin(SkinType.SKIN);
		toset = false;
		print("Both Skins Loaded"); 

	# Handle Error
	elif (skin_s == Lod.Stat.FAILED or boat_skin_s == Lod.Stat.FAILED):
		print("Error: One of the skins failed to load!");

func takeDamage(amount: float) -> void:
	# Wait for cooldown
	if not coolDownTimer.is_stopped(): return;

	# Show Health for a while
	if healthBarTimer.is_stopped():
		# Hide name 
		playerName.visible = false;
		# Create Timer for Health bar
		healthBarTimer.start(healthBarTime);
		healthBar.visible = true;
	
	# Deduct damage
	playerHealth -= amount;
	playerHealth = max(0, playerHealth);
	healthBar.value = playerHealth;

	# Check player death 
	if (playerHealth <= 0.0):
		stateManager.changeState(stateManager.States.DEATH);
		return;
	
	# Show hurt animation
	if hurtTimer.is_stopped():
		hurtTimer.start(1);
		handleHurtAnimation();
	
	# Setup Tween
	var tween = create_tween().set_loops(3);
	tween.tween_property(texture, "modulate:a", 0.05, 0.08);
	tween.tween_property(texture, "modulate:a", 1.0, 0.08);
	
	# Start Timer
	coolDownTimer.start(coolDownTime);

func getWeapon() -> Node2D:
	if weaponHolder and weaponHolder.get_child(0):
		return weaponHolder.get_child(0);
	else: return null;

func getVehicle(body: CharacterBody2D = null) -> CharacterBody2D:
	var check = vehicle if not body else body; 
	if ( 
		is_instance_valid(check) and 
		not check.is_queued_for_deletion() and 
		"stateManager" in check and
		check.stateManager
	): return check;
	
	else: return null;

func setVehicle(body: CharacterBody2D) -> void:
	vehicle = getVehicle(body);

func setZOrder(type: Variant) -> void:
	# Cache weapon 
	weapon = getWeapon();
	# Check type
	if type is StringName and type == &"Default":
		texture.z_index = 3;
		if weapon: weapon.z_index = 0;
	elif type is int:
		texture.z_index = type;
		if weapon: weapon.z_index = type;

func removeVehicle() -> void:
	vehicle = null;

func setPlayerSkin(type: SkinType):
	match type:
		SkinType.SKIN:
			texture.sprite_frames = playerSkinTexture;
			collider.set_deferred("shape", playerSkinCollider);
			collider.position.x = playerData.skins[currentPlayerSkin][4][0];
			collider.position.y = playerData.skins[currentPlayerSkin][4][1];
			texture.position.x 	= playerData.skins[currentPlayerSkin][4][2][0];
			texture.position.y 	= playerData.skins[currentPlayerSkin][4][2][1];
		SkinType.BOAT:
			texture.sprite_frames = playerBoatTexture;
			collider.set_deferred("shape", playerBoatCollider);
			collider.position.x = playerData.skins[currentPlayerSkin][5][0];
			collider.position.y = playerData.skins[currentPlayerSkin][5][1];
			texture.position.x 	= playerData.skins[currentPlayerSkin][5][2][0];
			texture.position.y 	= playerData.skins[currentPlayerSkin][5][2][1];

func showOutLine(flag: bool) -> void:
	if flag: 
		# Start the outline timer
		if outlineTimer.is_stopped():
			outlineTimer.start(0.12);
		# Show player outline
		outline.visible = true;
		processOutline();

	else: 
		# Stop outline timer
		if not outlineTimer.is_stopped():
			outlineTimer.stop();
		# Hide player outline
		outline.visible = false;
		# Hide weapon outline 
		if weapon and weapon.has_method("showOutline"):
			weapon.showOutline(false);

func showWeaponOutline() -> void:
	# Show weapon outline 
	if weapon and weapon.has_method("showOutline"):
		weapon.showOutline(true);

func getGround() -> TileMapLayer:
	var tmp: TileMapLayer = get_tree().get_first_node_in_group("Ground");
	if tmp: return tmp;
	else: return null;

func handleSwitch(_packet: Dictionary) -> void:
	# Disconnect Signal 
	if Manager.cameraSwitched.is_connected(handleSwitch):
		Manager.cameraSwitched.disconnect(handleSwitch);

	# Check MetaData
	if metaData[&"inVehicle"]:
		var vehical = instance_from_id(metaData[&"vehicleId"]);
		# If Vehicle Exist
		if vehical:
			# Check Vehicle Type
			match metaData[&"vehicleType"]:
				&"Ship":
					stateManager.changeState(stateManager.States.IN_SHIP);
				# TODO: Plane steup heres
	else:
		# Handle Non Vehicle 
		stateManager.changeState(stateManager.States.IDLE);

func handleAnim() -> void:
	if abs(lasDir.x) > abs(lasDir.y):
		# Check Horizontal
		if lasDir.x > 0.1:
			animManager.play("idle_right")
		elif lasDir.x < -0.1:
			animManager.play("idle_left")
	else:
		# Check Vertical
		if lasDir.y > 0.1:
			animManager.play("idle_down")
		elif lasDir.y < -0.1:
			animManager.play("idle_up")

func handleHurtAnimation() -> void:
	if abs(lasDir.x) > abs(lasDir.y):
		# Check Horizontal
		if lasDir.x > 0.1:
			animManager.play("hurt_right")
		elif lasDir.x < -0.1:
			animManager.play("hurt_left")
	else:
		# Check Vertical
		if lasDir.y > 0.1:
			animManager.play("hurt_down")
		elif lasDir.y < -0.1:
			animManager.play("hurt_up")

func setNameColor(color: String) -> void:
	var pName = str(self.name);
	var f = "[color=" + color + "]" + pName + "[/color]";
	if not pName.is_empty():
		playerName.text = f;

func getMetaData() -> Dictionary:
	return metaData;

func clearMetaData() -> void:
	metaData[&"inVehicle"] = false;
	metaData[&"vehicleType"] = null;
	metaData[&"vehicleId"] = null;
