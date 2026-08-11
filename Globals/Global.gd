extends Node;

# Default Variables
var defaultShipSkin: int;
var defaultPlayerSkin: int;
var defaultLoadTime: float;
var defaultShipSpeed: float;
var defaultShipHealth: float;
var defaultBoostShipSpeed: float;
var playerSpeed: float;
var defaultShipDrag: float;
var playerRunSpeed: float;
var defaultPlayerHeath: float;
var defaultShipDamage: float;
var shipSinkDamage: float;
var oceanFriction: float;
var planeHeath: float;
var planeSpeed: float;
var planeDamage: float;
var planeBoostSpeed: float;
var airFriction: float;
var defaultCameraZoom: Vector2;

# Init Globals
func _ready() -> void:
	playerSpeed = 100.0;
	defaultShipDrag = 650.0;
	playerRunSpeed = 150.0;
	defaultShipSkin = 0;
	defaultPlayerSkin = 0;
	defaultShipSpeed = 100.0;
	defaultShipHealth = 50.0;
	defaultPlayerHeath = 100.0;
	defaultShipDamage = 50.0;
	shipSinkDamage = 50.0;
	oceanFriction = 100.0;
	planeHeath = 200.0;
	planeSpeed = 400.0;
	planeBoostSpeed = 600.0;
	planeDamage = 100.0;
	airFriction = 80.0;
	defaultCameraZoom = Vector2(1.0, 1.0);
	defaultBoostShipSpeed = 200.0;
