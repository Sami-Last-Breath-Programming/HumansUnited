extends State;

# Variables
var ship: CharacterBody2D;

# Booleans
var isBoost = false;

func Entry() -> void:
	# Player Setup
	parent.camera.enabled = true;
	parent.texture.sprite_frames = parent.playerSkinTexture
	parent.collider.call_deferred("set_disabled", false);
	
func Exit() -> void:
	# Disable Camera
	parent.camera.enabled = false;
	parent.dust.emitting = false;
	parent.collider.call_deferred("set_disabled", true);

func HandleInput(_e: InputEvent) -> void:
	if _e.is_action_pressed("CameraSwitch"): switchCamera();	
	elif  _e.is_action_pressed("Boost"): isBoost = true;
	elif _e.is_action_released("Boost"): isBoost = false

func Update(_d: float) -> void:
	# Get Movement
	var input = Input.get_vector(
		"Left", "Right", "Up", 
		"Down"
	);
	
	# Handle Joystic
	if (input == Vector2.ZERO):
		input = parent.externalInput;
		
	# Handle Rotation, Particles & Animation
	if (input != Vector2.ZERO):
		parent.dust.emitting = true;
	else:
		parent.dust.emitting = false;
	
	# Movement
	parent.velocity = input * (Global.playerRunSpeed if isBoost else Global.playerSpeed);
	parent.move_and_slide();

func switchCamera(): 
	Manager.reqPlayerSwitch.emit(parent);
	stateManager.changeState(stateManager.States.DISABLED);	
