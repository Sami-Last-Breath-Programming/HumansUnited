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
		
	# Change state to default 	
	StateData[currentState].Entry();
	processSetup(StateData[currentState], true);

func changeState(state: int) -> void:
	# Stop the old state
	StateData[currentState].Exit();
	processSetup(StateData[currentState], false);
	# Start the new state
	StateData[state].Entry();
	processSetup(StateData[currentState], true);
	# Cache the new state
	lastState = currentState;
	currentState = state;

func _process(delta: float) -> void:
	StateData[currentState].Update(delta)

func _physics_process(delta: float) -> void:
	StateData[currentState].PhysicsUpdate(delta)

func _unhandled_input(event: InputEvent) -> void:
	StateData[currentState].HandleInput(event)

func delete() -> void:
	StateData[currentState].Exit();
	processSetup(StateData[currentState], false);
	self.get_parent().queue_free();

func processSetup(n: Node, b: bool) -> void:
	n.set_process(b);
	n.set_process_input(b);
	n.set_physics_process(b);
	n.set_process_unhandled_input(b)
