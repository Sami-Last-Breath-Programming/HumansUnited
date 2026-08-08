extends State;

var driver: CharacterBody2D;

func Entry() -> void:
   # Setup Plane
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
	
	# Driver exist
	driver = parent.getDriver()
	
	# Handle driver 
	if (driver):
		# Change driver to in Plane State
		driver.stateManager.changeState(driver.stateManager.States.IN_SHIP); # TO DO ADD IN_PLANE
		# Change to Fly State
		stateManager.changeState.call_deferred((stateManager.States.FLY));
	
	# Cooldown	
	var hud = Manager.getHud();
	hud.enableBtn(hud.Buttons.BOOST);
	parent.enterTimer.start(parent.coolDownTime);