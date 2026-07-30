extends Node;

# Default Variables
var defaultShipSkin: int;
var defaultPlayerSkin: int;
var defaultShipSpeed: float;
var defaultShipHealth: float;
var defaultBoostShipSpeed: float;
var playerSpeed: float;
var playerRunSpeed: float;
var defaultPlayerHeath: float;
var defaultShipDamage: float;
var shipSinkDamage: float;
var defaultCameraZoom: Vector2;
var defaultVehicleCameraZoom: Vector2;

# Init Globals
func _ready() -> void:
	playerSpeed = 100.0;
	playerRunSpeed = 150.0;
	defaultShipSkin = 0;
	defaultPlayerSkin = 0;
	defaultShipSpeed = 100.0;
	defaultShipHealth = 50.0;
	defaultPlayerHeath = 100.0;
	defaultShipDamage = 50.0;
	shipSinkDamage = 80.0;
	defaultCameraZoom = Vector2(1.8, 1.8);
	defaultVehicleCameraZoom = Vector2(1.0, 1.0);
	defaultBoostShipSpeed = 200.0;
