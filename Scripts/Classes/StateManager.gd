class_name StateManager
extends Node

# States
var States: Dictionary = {
	"NULL" : 0,	
};

# Lazy Load
@onready var currentState: int = 1;

# Variables
var StateData = {};
var lastState: int = States.NULL;
var currentStateRef: State;

func init() -> void:
	# Loop on all States and refer StateManager
	var count: int = 1;
	for node in self.get_children():
		if node is State:
			node.stateManager = self;
			node.parent = self.get_parent();
			node.id = count;
			
			# Set State and State Data
			States[node.name.to_upper()] = count;
			StateData[count] = node;
			
			# Disable Process
			processSetup(node, false);
			count += 1;

	# Get the current state ref
	currentStateRef = StateData[currentState];

	# Change state to default 	
	currentStateRef.Entry();
	processSetup(currentStateRef, true);

func changeState(state: int) -> void:
	# Cache the last state
	lastState = currentState;
	# Stop the old state
	currentStateRef.Exit();
	processSetup(currentStateRef, false);
	
	# Get the current state ref
	currentState = state;
	currentStateRef = StateData[currentState];
	
	# Start the new state
	processSetup(currentStateRef, true);
	currentStateRef.Entry();

func _process(delta: float) -> void:
	currentStateRef.Update(delta)

func _physics_process(delta: float) -> void:
	currentStateRef.PhysicsUpdate(delta)

func _unhandled_input(event: InputEvent) -> void:
	currentStateRef.HandleInput(event)

func getCurrentState() -> int:
	return currentState;

func delete() -> void:
	currentStateRef.Exit();
	processSetup(currentStateRef, false);
	self.get_parent().queue_free();

func processSetup(n: Node, b: bool) -> void:
	n.set_process(b);
	n.set_process_input(b);
	n.set_physics_process(b);
	n.set_process_unhandled_input(b)
