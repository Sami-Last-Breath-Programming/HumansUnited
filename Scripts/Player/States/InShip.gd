extends State;

# Variables
var player = parent as CharacterBody2D;;
var ship: CharacterBody2D;

func Entry() -> void:
	# Ship Exist
	ship = player.getShip();
	# Enable Ship
	if (ship):
		ship.stateManager.changeState(ship.stateManager.States.DRIVING);
	# Player setup
	player.position = Vector2.ZERO;
	player.texture.sprite_frames = player.playerBoatTexture;

func Exit() -> void:
	player.texture.sprite_frames = player.playerSkinTexture;

func HandleInput(_e: InputEvent) -> void:
	if _e.is_action_pressed("CameraSwitch"): switchCamera();

func switchCamera(): 
	Manager.reqPlayerSwitch.emit(player);
	stateManager.changeState(stateManager.States.DISABLED);	

	# Ship Exist
	ship = player.getShip();
	var last = ship;
	if (ship):
		ship.stateManager.changeState(ship.stateManager.States.DISABLED);
		player.setShip(last);
