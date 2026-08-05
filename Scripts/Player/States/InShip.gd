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
	
	# Switch request to manager
	Manager.reqPlayerSwitch.emit(parent);
	stateManager.changeState(stateManager.States.DISABLED);	
	
	# Ship Exist
	ship = parent.getShip();
	# Disable Ship
	var last = ship;
	if ship:
		ship.stateManager.changeState(ship.stateManager.States.DISABLED);
		parent.setShip(last);
