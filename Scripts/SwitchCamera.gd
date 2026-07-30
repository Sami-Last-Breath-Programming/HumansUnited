extends Camera2D;

# Variables
var player: CharacterBody2D;
var playerCamera: Camera2D;
var closestPlayer: CharacterBody2D;
var closestPlayerCamera: Camera2D;
var closestDistant: float = INF;

func _ready() -> void:
	# Get player camera
	playerCamera = player.getCamera();	

	# Set the Camera Properties
	self.global_position = player.global_position;
	self.zoom = playerCamera.zoom;
	
	# Set Camera
	self.make_current();
	
	# Find the closest player
	findClosestPlayer();
	
	# Play and Free
	playAnim();

func findClosestPlayer() -> void:
	# Get All player nodes
	var players: Array[Node] = get_tree().get_nodes_in_group("Player");
	
	# Loop on Array
	for obj in players:
		# Check for Disabled
		if (obj.stateManager.currentState == obj.stateManager.States.DISABLED):
			
			# Leave if current player
			if obj == player: continue;
			
			# Get the Distance of Npc
			var npcDis = player.global_position.distance_squared_to(obj.global_position);
			# Store the smallest distance and player
			if (npcDis <= closestDistant):
				closestDistant = npcDis
				closestPlayer = obj;

func playAnim() -> void:
	
	# If all players dead
	if not closestPlayer: return; #TODO: Add Death Screen
 	
	# Get the closest player camera
	closestPlayerCamera = closestPlayer.getCamera();
	
	# Create a tween
	var tween = create_tween();
	tween.tween_property(self, "zoom", Vector2(1.0, 1.0), 0.5);
	tween.tween_property(self, "global_position", closestPlayer.global_position, 1.2);
	tween.tween_property(self, "zoom", closestPlayerCamera.zoom, 0.5);
	
	# Wait for animation finised
	tween.finished.connect(func ():
		self.enabled = false;
		
		# Ship Exist
		var ship = closestPlayer.getShip();
		if (ship):
			closestPlayer.stateManager.changeState(closestPlayer.stateManager.States.IN_SHIP);
		else:
			closestPlayer.stateManager.changeState(closestPlayer.stateManager.States.IDLE);
		self.queue_free();
	)
