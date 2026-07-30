extends StateManager

# Default Disabled
@export var shipState: int = 1;

func init() -> void:
	currentState = shipState;
	super();
