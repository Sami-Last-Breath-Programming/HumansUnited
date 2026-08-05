extends State;

# Variables
var ship: CharacterBody2D;
var anim: Node;
enum {WATER = 16};

# Booleans
var isBoost = false;
var inWater = false;
var isSplashed = false;

func Entry() -> void:
	# Player Setup
	parent.camera.enabled = true;
	parent.texture.sprite_frames = parent.playerSkinTexture
	parent.collider.call_deferred("set_disabled", false);
	# Animation setup
	anim = parent.animManager;
	
func Exit() -> void:
	# Disable Camera
	parent.camera.enabled = false;
	parent.dust.emitting = false;
	# Disable Water Effects 
	if inWater:
		anim.stop(anim.Anim.SPLASH);
		anim.stop(anim.Anim.SWIM);
		isSplashed = false;
	# Enable Collider
	parent.collider.call_deferred("set_disabled", true);

func HandleInput(_e: InputEvent) -> void:
	if _e.is_action_pressed("CameraSwitch"): switchCamera();	
	elif  _e.is_action_pressed("Boost"): isBoost = true;
	elif _e.is_action_released("Boost"): isBoost = false

func Update(_d: float) -> void:
	# Check Water
	checkWater();
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
		if inWater: 
			anim.play(anim.Anim.SWIM);
			parent.dust.emitting = false;
		else: parent.dust.emitting = true;
	else:
		parent.dust.emitting = false;
		if inWater: anim.stop(anim.Anim.SWIM);
	
	# Movement
	parent.velocity = input * (Global.playerRunSpeed if isBoost else Global.playerSpeed);
	parent.move_and_slide();

func checkWater() -> void:
	# Get The Chuck Grounds
	var grounds: Array[Node] = get_tree().get_nodes_in_group("Ground");
	# Loop over Grounds
	for ground in grounds:
		# If Ground not null and TileMap
		if (ground and ground is TileMapLayer):
			# Player feet position
			var local_pos = ground.local_to_map(parent.global_position);
			# Get ground tile 
			var g_tile = ground.get_cell_source_id(local_pos);
			# Check if on ground tile 
			if g_tile != -1: 
				inWater = false;
				anim.stop(anim.Anim.SWIM);	
				isSplashed = false;
			else: 
				if isSplashed and parent.splashTimer.is_stopped(): 
					anim.stop(anim.Anim.SPLASH);
				if not isSplashed:
					anim.play(anim.Anim.SPLASH);
					parent.splashTimer.start(1);
					isSplashed = true;
					inWater = true;

func switchCamera(): 
	Manager.reqPlayerSwitch.emit(parent);
	stateManager.changeState(stateManager.States.DISABLED);	
