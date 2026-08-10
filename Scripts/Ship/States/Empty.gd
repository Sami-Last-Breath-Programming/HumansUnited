extends State;

# Variables
var driver: CharacterBody2D;

func Entry() -> void:
	# Setup Ship
	parent.velocity = Vector2.ZERO;
	# Connect Detector
	parent.detector.body_entered.connect(driverEnter);
	
func Exit() -> void:
	parent.detector.body_entered.disconnect(driverEnter);
	parent.velocity = Vector2.ZERO;

func driverEnter(body: Node2D):
	# Don't React
	if not body is CharacterBody2D: return;
	if not parent.enterTimer.is_stopped(): return;
	if not parent.exitTimer.is_stopped(): return;
	if not body.is_in_group("Player"): return;
	
	# Setup driver
	parent.setDriver(body);

	# Emit signal 
	var packet: Dictionary = {
		&"id": parent.get_instance_id(),
		&"vehicle":&"Ship",
	};
	Manager.driverEnter.emit(packet);

	# Change to Driving state
	stateManager.changeState.call_deferred((stateManager.States.DRIVING));

	# Cooldown	
	parent.enterTimer.start(parent.coolDownTime);
