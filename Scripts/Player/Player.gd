extends CharacterBody2D;

enum Health {STILL, GONE, Cooldown}
enum SkinType {SKIN, BOAT}

# Lazy Load 
@onready var dust := $Dust;
@onready var texture := $Texture;
@onready var camera := $Camera;
@onready var outline := $Outline;
@onready var healthBar := $Progress;
@onready var collider: CollisionShape2D = $Collision;
@onready var stateManager := $StateManager;
@onready var animManager := $AnimManager;
@onready var playerData := PlayerData.new();

# Exported
@export var playerHealth: float;
@export var currentPlayerSkin: int;

# Shared Variable
var externalInput: Vector2 = Vector2.ZERO;

# Variables
var result := [null];
var coolDownTime := 0.5;
var healthBarTime := 2.4;
var coolDownTimer := Timer.new();
var healthBarTimer := Timer.new();
var isEntredWaterTimer := Timer.new();
var ship: CharacterBody2D = null;
var playerBoatTexture: SpriteFrames = null;
var playerSkinTexture: SpriteFrames = null;
var playerSkinCollider: Resource = null;
var playerBoatCollider: Resource = null;

# Booelans
var toset: bool = false;
var isCooldown: bool = false;

func _ready() -> void:
	# Init State Manager
	stateManager.init();
	
	# Set the Default Player Skin
	setSkin(currentPlayerSkin);
	setPlayerProperties();
	
	# Set Health Bar and Timer
	healthBar.visible = false;
	healthBar.value = playerHealth;
	healthBar.max_value = playerHealth;
	self.add_child(coolDownTimer);
	self.add_child(healthBarTimer);
	self.add_child(isEntredWaterTimer);
	isEntredWaterTimer.one_shot = true;
	coolDownTimer.one_shot = true;
	healthBarTimer.one_shot = true;
	healthBarTimer.timeout.connect(func():healthBar.visible = false);
	
func _process(_delta: float) -> void:
	processSkin();
	
func setSkin(index: int) -> void:
	# Request resource loader to load skin
	toset = true;
	currentPlayerSkin = index;
	# Request Resource Load
	for res in playerData.skins[currentPlayerSkin]:
		if res is String:
			Lod.req(res);	

func setPlayerProperties() -> void:
	if not playerHealth: 		playerHealth = Global.defaultPlayerHeath;
	if not currentPlayerSkin: 	currentPlayerSkin = Global.defaultPlayerSkin;

func getSkin(index: int) -> String:
	return playerData.skins[currentPlayerSkin][index];

func processOutline() -> void:
	outline.sprite_frames = texture.sprite_frames;
	outline.position = texture.position;

func processSkin() -> void:
	if not toset:
		return;

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
		toset = false;

func takeDamage(amount: float) -> Health:
	# Wait for cooldown
	if not coolDownTimer.is_stopped(): return Health.Cooldown;
	
	# Show Health for a while
	if healthBarTimer.is_stopped():
		# Create Timer for Health bar
		healthBarTimer.start(healthBarTime);
		healthBar.visible = true;
	
	# Deduct damage
	playerHealth -= amount;
	playerHealth = max(0, playerHealth);
	healthBar.value = playerHealth;
	
	print(playerHealth);
	
	# Check player death 
	if (playerHealth <= 0.0):
		stateManager.changeState(stateManager.States.DEATH);
		print("Player death: ", self);
		return Health.GONE;
	
	# Show Damage Animation
	var tween = create_tween().set_loops(3);
	tween.tween_property(texture, "modulate:a", 0.05, 0.08);
	tween.tween_property(texture, "modulate:a", 1.0, 0.08);
	
	# Start Timer
	coolDownTimer.start(coolDownTime);
	
	# Driver Alive
	return Health.STILL;
	
func getCamera() -> Camera2D:
	return camera;

func getShip(body: CharacterBody2D = null) -> CharacterBody2D:
	var check = ship if not body else body; 
	if ( 
		is_instance_valid(check) and 
		not check.is_queued_for_deletion() and 
		"stateManager" in check and
		check.stateManager
	): return check;
	
	else: return null;

func setShip(body: CharacterBody2D) -> void:
	ship = body;

func removeShip() -> void:
	ship = null;

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
	if flag: outline.visible = true;
	else: outline.visible = false;
