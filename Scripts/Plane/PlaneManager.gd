extends StateManager;

# Default Idle 
@export var planeState: int = 1;

func init() -> void:
    currentState = planeState;
    super();