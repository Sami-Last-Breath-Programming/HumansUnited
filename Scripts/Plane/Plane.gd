extends CharacterBody2D;

# Lazy Load
@onready var texture: AnimatedSprite2D = $Texture;
@onready var stateManager: Node = $StateManager;
@onready var planeCamera: Camera2D = $Camera;
@onready var detector: Area2D = $Detector;
@onready var planeCollider: CollisionShape2D = $Body
@onready var planeWingsCollider: CollisionShape2D = $Wings;
@onready var healthBar: TextureProgressBar = $HealthBar;

# Editor Exposed 
@export var planeDrag: float;
@export var planeHeath: float;
@export var planeSpeed: float;
@export var planeDamage: float;
@export var planeBoostSpeed: float;

# Variables
var enterTime: float = 0.2;
var damageTime: float = 0.5;
var exitTime: float = 0.6;
var healthBarTime: float = 2.4;
var coolDownTime: float = 0.6;
var exitTimer: Timer = Timer.new();
var damageTimer := Timer.new();
var enterTimer: Timer = Timer.new();
var coolDownTimer: Timer = Timer.new();
var healthBarTimer: Timer = Timer.new();
var driver: CharacterBody2D = null;

# Boolean
var damageSpeedApplied: bool = false;

func _ready() -> void:
	# Init State Manager 
	stateManager.init();
   
	# Set the defaults
	setPlaneProperties()
	
	# Setup Health Bar
	healthBar.visible = false;
	healthBar.value = planeHeath;
	healthBar.max_value = planeHeath;

	# Setup timer
	self.add_child(enterTimer);
	self.add_child(exitTimer);
	self.add_child(damageTimer);
	self.add_child(coolDownTimer);
	self.add_child(healthBarTimer);
	enterTimer.one_shot = true;
	damageTimer.one_shot = true;
	exitTimer.one_shot = true;
	coolDownTimer.one_shot = true;
	healthBarTimer.one_shot = true;

func setPlaneProperties() -> void:
	if not planeDrag:           planeDrag           = Global.airFriction;
	if not planeHeath:          planeHeath          = Global.planeHeath;
	if not planeSpeed:          planeSpeed          = Global.planeSpeed;
	if not planeDamage:         planeDamage         = Global.planeDamage;
	if not planeBoostSpeed:     planeBoostSpeed     = Global.planeBoostSpeed;

func takeDamage(amount: float) -> void:
	# Wait for cooldown 
	if not coolDownTimer.is_stopped(): return

	# Create Timer for Health Bar 
	if healthBarTimer.is_stopped():
		healthBarTimer.start(healthBarTime);
		healthBar.visible = true;

	# Deduct Damage 
	planeHeath -= amount;
	planeHeath = max(0, planeHeath);
	healthBar.value = planeHeath;

	# Check for Crashed
	if (planeHeath <= 0.0):
		texture.play("crashed");
		stateManager.changeState(stateManager.States.CRASHED);

	# Check for Plane Damage Ratio 
	var ratio: int = int((planeHeath / healthBar.max_value) * 100);

	# Handle Health Variations
	if (ratio <= 35):
		# Reduce Speed
		if (not damageSpeedApplied):
			var hud = Manager.getHud();
			var currentState = stateManager.getCurrentState();
			# Only hide hud if Flying state 
			if (hud and currentState == stateManager.States.FLY):
				hud.disableBtn(hud.Buttons.BOOST);
			planeSpeed /= 2.0;
			planeBoostSpeed = 0.0;
			damageSpeedApplied = true;

	# Show Damage Animation
	var tween = create_tween().set_loops(3);
	tween.tween_property(texture, "modulate:a", 0.3, 0.08);
	tween.tween_property(texture, "modulate:a", 1.0, 0.08);

	# Cooldown 
	coolDownTimer.start(coolDownTime);

func setDriver(d: CharacterBody2D) -> void:
	if d: driver = d;
	else: driver = null;

func getDriver(d: CharacterBody2D = null) -> CharacterBody2D:
	var check: CharacterBody2D = driver if not d else d;
	if (
		is_instance_valid(check) and 
		not check.is_queued_for_deletion() and 
		"stateManager" in check and 
		check.stateManager
	): return check;

	else: return null;

func processFriction(_d) -> void:
	self.velocity = velocity.move_toward(Vector2.ZERO, _d * planeDrag);

func removeDriver() -> void:
	driver = null;
