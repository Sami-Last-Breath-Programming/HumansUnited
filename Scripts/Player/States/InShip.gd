extends State;

# Variables
var ship: CharacterBody2D;

func Entry() -> void:
	# Ship Exist
	ship = parent.getShip();
	# Enable Ship
	if (ship):
		ship.stateManager.changeState(ship.stateManager.States.DRIVING);
	# Player setup
	parent.position = Vector2.ZERO;
	parent.texture.sprite_frames = parent.playerBoatTexture;

func Exit() -> void:
	parent.texture.sprite_frames = parent.playerSkinTexture;

func HandleInput(_e: InputEvent) -> void:
	if _e.is_action_pressed("CameraSwitch"): switchCamera();
	
func switchCamera(): 
	# Ship Exist
	ship = parent.getShip();
	# Handle Ship sinking
	if (not ship): return;
	# Hold reference
	var last = ship;
	
	# Hud Exist
	var hud = Manager.getHud();
	# Switch request to Hud
	if hud: hud.reqCamList.emit(parent);
	
	# Set reference
	parent.setShip(last);
