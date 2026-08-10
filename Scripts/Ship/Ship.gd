extends CharacterBody2D;

# Lazy Load
@onready var texture := $Texture;
@onready var stateManager := $StateManager;
@onready var shipCollider := $Collision;
@onready var particle := $Texture/Particle;
@onready var sinkParticle := $Texture/Sink;
@onready var healthBar := $Progress;
@onready var detector := $Detect
@onready var shipData := ShipData.new();

# Editor Exposed
@export var shipDrag: float;
@export var shipSkin: int;
@export var shipHealth: float;
@export var shipSpeed: float;
@export var shipDamage: float;
@export var boostShipSpeed: float;

# Variables
var result := [null];
var damageTime := 0.5;
var exitTime := 0.6;
var healthBarTime := 2.4;
var coolDownTime := 0.6;
var exitTimer := Timer.new();
var enterTimer := Timer.new();
var damageTimer := Timer.new(); 
var coolDownTimer := Timer.new();
var healthBarTimer := Timer.new();
var loadedSkins := [null, null, null, null];
var driver: CharacterBody2D = null;

# Booleans
var toset := false;
var damageSpeedApplied := false;
var canUpdatePhysics := false;

func _ready() -> void:	
	# Init State Manager
	stateManager.init();
	
	# Set the defaults
	setSkin(shipSkin);
	setShipProperties();
	
	# Setup Health Bar and Timer
	healthBar.visible = false;
	healthBar.value = shipHealth;
	healthBar.max_value = shipHealth;
	self.add_child(enterTimer);
	self.add_child(exitTimer);
	self.add_child(damageTimer);
	self.add_child(coolDownTimer);
	self.add_child(healthBarTimer);
	enterTimer.one_shot = true;
	exitTimer.one_shot = true;
	damageTimer.one_shot = true;
	coolDownTimer.one_shot = true;
	healthBarTimer.one_shot = true;
	healthBarTimer.timeout.connect(func(): healthBar.visible = false);

func _process(_delta: float) -> void:
	processSkin();

func setSkin(index: int) -> void:
	# Request the skin load
	toset = true;
	shipSkin = index;
	
	# Loop on textures
	for res in shipData.skins[shipSkin]:
		if (res is String and res != ""): Lod.req(res);
	return;

func setShipProperties() -> void:
	if not shipDrag:			shipDrag			= Global.defaultShipDrag;
	if not shipSkin: 			shipSkin 			= Global.defaultShipSkin;
	if not shipHealth:			shipHealth 			= Global.defaultShipSpeed;
	if not shipSpeed:			shipSpeed 			= Global.defaultShipHealth;
	if not shipDamage:			shipDamage 			= Global.defaultShipDamage;
	if not boostShipSpeed: 		boostShipSpeed 		= Global.defaultBoostShipSpeed;

func processSkin() -> void:
	# Check if Skin Loaded
	if toset:
		# Loop on Skins Array
		for res in shipData.skins[shipSkin]:
			# Make Sure .res is Loaded
			var isStr: bool = (res is String and res != "");
			# Check the status
			if (isStr and Lod.stat(res, result) == Lod.Stat.LOADED):
				changeSkin(res);

func processFriction(_d) -> void:
	self.velocity = velocity.move_toward(Vector2.ZERO, _d * Global.oceanFriction);

func changeSkin(res: String) -> void:
	# Change skin, scale and collider
	loadedSkins[shipData.skins[shipSkin].find(res)] = (Lod.grep(res));
	texture.texture = loadedSkins[0];
	texture.scale.x = shipData.skins[shipSkin][-1];
	texture.scale.y = shipData.skins[shipSkin][-1];
	shipCollider.shape.radius = shipData.skins[shipSkin][-2][0];
	shipCollider.shape.height = shipData.skins[shipSkin][-2][1];
	shipCollider.position.x = shipData.skins[shipSkin][-2][2][0];
	shipCollider.position.y = shipData.skins[shipSkin][-2][2][1];
	toset = false;

func takeDamage(amount: float) -> void:
	# Wait for cooldown
	if not coolDownTimer.is_stopped(): return
	
	# Create Timer for Health bar
	if healthBarTimer.is_stopped():
		healthBarTimer.start(healthBarTime);
		healthBar.visible = true;
	
	# Deduct damage
	shipHealth -= amount;
	shipHealth = max(0, shipHealth);
	healthBar.value = shipHealth;
	
	# Check For sink
	if (shipHealth <= 0.0): 
		sinkParticle.emitting = false;
		stateManager.changeState(stateManager.States.SINKING);
	
	# Check The Ship Damage Ratio
	var ratio: int = int((shipHealth / healthBar.max_value) * 100);
	
	# Swap Textures
	if (ratio <= 35):
		if(loadedSkins[2]): texture.texture = loadedSkins[2];
		# Reduce Speed
		if (not damageSpeedApplied):
			shipSpeed /= 2.0; 
			boostShipSpeed = 0.0;
			damageSpeedApplied = true;
			sinkParticle.emitting = true;
			Manager.vehicalLowHp.emit(getDriver());
	elif (ratio <= 65):
		if(loadedSkins[1]): texture.texture = loadedSkins[1];
	
	# Show Damage Animation
	var tween = create_tween().set_loops(3);
	tween.tween_property(texture, "modulate:a", 0.3, 0.08);
	tween.tween_property(texture, "modulate:a", 1.0, 0.08);
	
	# Cooldown
	coolDownTimer.start(coolDownTime);

func setDriver(d: CharacterBody2D) -> void:
	if d: driver = d;
	else: driver = null;

func getDriver(body: CharacterBody2D = null) -> CharacterBody2D:
	var check = driver if not body else body; 
	if (
		is_instance_valid(check) and 
		not check.is_queued_for_deletion() and 
		"stateManager" in check and
		check.stateManager
	): return check;
	
	else: return null;

func removeDriver() -> void:
	driver = null;

func hasRoof() -> bool:
	return shipSkin in shipData.roofs;
