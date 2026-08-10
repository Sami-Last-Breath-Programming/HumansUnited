extends StateManager

# Default Disabled
@export var playerState: int = 4;

func init() -> void:
	currentState = playerState;
	super();