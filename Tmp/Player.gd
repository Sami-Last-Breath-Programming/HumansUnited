extends CharacterBody2D;

# Lazy Load
@onready var dust: GPUParticles2D = $Dust;
@onready var texture: AnimatedSprite2D = $Texture;
@onready var camera: Camera2D = $Camera;
@onready var healthBar: TextureProgressBar = $Progress;
@onready var collider: CollisionShape2D = $Collision

# Player State
enum State {
	NPC,  DEAD,
	IDLE, IN_SHIP
}

# Player Skins
@onready var skins: Dictionary = {
	0:	[
			"res://Resources/Skins/Player/1/skin.tres",
			"res://Resources/Skins/Player/1/boat.tres"
		],
};

# Exported
@export var playerHealth: float;
@export var currentState: State = State.NPC;

# Shared Variable
var external_boost: bool = false;
var external_CamSwitch: bool = false;
var external_input: Vector2 = Vector2.ZERO;

# Variables
var result: Array;
var currentPlayerSkin: int;
var healthBar_timer: Timer;
var healthBar_time: float;
var damage_time: float;
var ship: CharacterBody2D = null;
var playerBoatTexture: SpriteFrames = null;
var playerSkinTexture: SpriteFrames = null;

# Booelans
var toset: bool = false;
var is_cooldown: bool = false;

func _ready() -> void:
	# Set Defaults
	if not playerHealth: playerHealth = Global.defaultPlayerHeath;
	if not currentPlayerSkin: currentPlayerSkin = Global.defaultPlayerSkin;
	damage_time = 0.5;
	healthBar_time = 2.4;
	
	# Check for NCP
	if (currentState == State.NPC): camera.enabled = false;
	
	# Create the timer
	healthBar_timer = Timer.new();
	self.add_child(healthBar_timer);
	healthBar_timer.one_shot = true;
	healthBar_timer.timeout.connect(func ():
		healthBar.visible = false;
	);
	
	# Set the Default Player Skin
	setSkin(currentPlayerSkin);

func _process(_delta: float) -> void:
	# Check for skins loaded
	processSkin();
	
	# Keep eye on player health
	if (playerHealth <= 0.0 and currentState != State.DEAD ):
		currentState = State.DEAD;

func _physics_process(_delta: float) -> void:
	# Check flag
	match currentState:
		State.NPC:
			dust.emitting = false;
			return;
		State.IN_SHIP:
			return;
		State.DEAD:
			handleDeath();
		State.IDLE:
			processMovement();
			move_and_slide();

func _input(event: InputEvent) -> void:
		if (event.is_action_pressed("CameraSwitch")):
			switchCamera();

func processMovement():
	# Get Movement
	var input = Input.get_vector(
		"Left", "Right", "Up", 
		"Down"
	);
	
	# Handle Joystic
	if (input == Vector2.ZERO):
		input = external_input;
		
	# Handle Rotation, Particles & Animation
	if (input != Vector2.ZERO):
		dust.emitting = true;
	else:
		dust.emitting = false;
	
	# Movement
	var speed = getSpeed();
	self.velocity = input * speed;

func setSkin(index: int) -> void:
	# Request resource loader to load skin
	toset = true;
	currentPlayerSkin = index;
	Lod.req(getSkin(0));	# Skin Load
	Lod.req(getSkin(1));	# Boat Player Skin Load

func processSkin() -> void:
	if not toset:
		return;

	# Get status
	var skin_s = Lod.stat(getSkin(0), result);
	var boat_skin_s = Lod.stat(getSkin(1), result);
	
	# Check if both ready
	if (skin_s == Lod.Stat.LOADED and boat_skin_s == Lod.Stat.LOADED):
		playerSkinTexture = Lod.grep(getSkin(0));
		playerBoatTexture = Lod.grep(getSkin(1));
		texture.sprite_frames = playerSkinTexture;
		toset = false;
		print("Both Skins Loaded");
	
	# Handle Error
	elif (skin_s == Lod.Stat.FAILED or boat_skin_s == Lod.Stat.FAILED):
		print("Error: One of the skins failed to load!");
		toset = false;

func takeDamage(amount: float) -> void:
	# Delay next damage
	if is_cooldown:
		return;
	
	# Create Timer for Health bar
	healthBar_timer.start(healthBar_time);
	healthBar.visible = true;
	
	# Deduct damage
	playerHealth -= amount;
	playerHealth = max(0, playerHealth);
	healthBar.value = playerHealth;
	
	# Trigger Cooling Cooldown
	startCooldown();

func startCooldown() -> void:
	# Set the flag
	is_cooldown = true;
	
	# Show Damage Animation
	var tween = create_tween().set_loops(3);
	tween.tween_property(texture, "modulate:a", 0.05, 0.08);
	tween.tween_property(texture, "modulate:a", 1.0, 0.08);
	
	# Wait for cooldown timer then disable cooldown
	await get_tree().create_timer(damage_time).timeout;
	is_cooldown = false;

func handleDeath() -> void:	
	# Shrink Animation
	var tween = create_tween();
	tween.set_parallel(true);
	
	# Properly ease and trans 
	tween.tween_property(self, "scale", Vector2.ZERO, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	# Delay cleanup by 2 seconds 
	tween.chain().tween_interval(2.0);
	
	# finished signal
	tween.finished.connect(func():
		self.velocity = Vector2.ZERO;
		self.queue_free();
	)
	
func enterShip(who: CharacterBody2D, shipNode: CharacterBody2D):
	if who == self:
		currentState = State.IN_SHIP;
		camera.enabled = false;
		dust.emitting = false;
		ship = shipNode;
		
		# Handle roof ships
		if ship.getSkin() not in [0]:
			texture.visible = false;
		else:
			texture.sprite_frames = playerBoatTexture;
			
		collider.call_deferred("set_disabled", true);
	
func exitShip(who: CharacterBody2D):
	if who == self:
		currentState = State.IDLE;
		camera.enabled = true;
		texture.sprite_frames = playerSkinTexture;
		if (not texture.visible): texture.visible = true;
		collider.call_deferred("set_disabled",false);
		ship = null;

func getCamera() -> Camera2D:
	return camera;

func getSkin(index: int) -> String:
	return skins[currentPlayerSkin][index];

func getSpeed() -> float:
	return 	Global.playerRunSpeed if \
			(Input.is_action_pressed("Boost") or external_boost) \
			else Global.playerSpeed;

func switchCamera() -> void:
	if (not Manager.isCameraSwitching and currentState not in [State.NPC, State.DEAD, State.IN_SHIP]):
			Manager.reqPlayerSwitch.emit(self);
