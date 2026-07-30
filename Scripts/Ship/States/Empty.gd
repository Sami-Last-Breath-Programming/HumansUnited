extends State;

# Variables
var ship = parent as CharacterBody2D;
var driver: CharacterBody2D;

func Entry() -> void:
	# Setup Ship
	ship.velocity = Vector2.ZERO;
	# Connect Detector
	ship.detector.body_entered.connect(driverEnter);
	
func Exit() -> void:
	ship.detector.body_entered.disconnect(driverEnter);

func driverEnter(body: Node2D):
	if not body is CharacterBody2D: return;
	if not ship.enterTimer.is_stopped(): return;
	if not ship.exitTimer.is_stopped(): return;
	
	# Setup driver
	ship.driver = body;
	
	# Driver exist
	driver = ship.getDriver()
	
	# Handle driver 
	if (driver):
		# Change driver to in Ship state
		driver.stateManager.changeState(driver.stateManager.States.IN_SHIP);
		# Change to Driving state
		stateManager.changeState.call_deferred((stateManager.States.DRIVING));
	
	# Cooldown	
	ship.enterTimer.start(ship.coolDownTime);
