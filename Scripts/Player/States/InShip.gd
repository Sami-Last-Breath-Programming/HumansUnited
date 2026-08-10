extends State;

func Entry() -> void:
	# Connect Signal 
	if (not Manager.driverExit.is_connected(handleExit)):
		Manager.driverExit.connect(handleExit);
	
	# Connect Lambda Signal
	Manager.cameraSwitching.connect(func():
		stateManager.changeState(stateManager.States.DISABLED),
		CONNECT_ONE_SHOT	
	)

	# Set metaData 
	parent.metaData[&"inVehicle"] = true;
	parent.metaData[&"vehicleType"] = &"Ship";
	parent.metaData[&"vehicleId"] = parent.getVehicle().get_instance_id();

	# Signal to Manager
	var mainCamera = Manager.getMainCamera();
	var packet: Dictionary = {
		&"vehicleId": parent.getVehicle().get_instance_id(),
		&"vehiclePos": parent.getVehicle().global_position,
	}
	if mainCamera: mainCamera.playerVehicleActive.emit(packet);

	# Player setup
	parent.position = Vector2.ZERO;
	parent.setPlayerSkin(parent.SkinType.BOAT);

func Exit() -> void:
	# Disconnect Signal 
	if Manager.driverExit.is_connected(handleExit):
		Manager.driverExit.disconnect(handleExit);
	
	parent.setPlayerSkin(parent.SkinType.SKIN);

func HandleInput(_e: InputEvent) -> void:
	# Handle Camera Switch
	if _e.is_action_pressed("CameraSwitch"): reqSwitch();

	# Handle Ship Exit
	if _e.is_action_pressed("VehicleExit"):
		# Sigant to Manager
		var packet: Dictionary = {
			&"vehicle": &"Ship",
			&"driver": parent.name,
			&"driverPos": parent.global_position,
			&"cameraZoom": Manager.getMainCamera().zoom,
		}
		Manager.driverExit.emit(packet);

	# Handle Driving Boost
	if _e.is_action_pressed("Boost"):
		var ship = parent.getVehicle();
		if ship: 
			if (ship.boostShipSpeed != 0.0):
				ship.handleBoost(true);
	elif _e.is_action_released("Boost"):
		var ship = parent.getVehicle();
		if ship: ship.handleBoost(false);
	
func handleExit(packet: Dictionary) -> void:
	if packet[&"vehicle"] != &"Ship": return;
	if packet[&"driver"] != parent.name: return;
	# Handle player ship
	stateManager.changeState(stateManager.States.IDLE);

func PhysicsUpdate(_d: float) -> void:
	var ship = parent.getVehicle();
	if not ship: return;

	# Set input to ship;
	var input =  Input.get_vector("Left", "Right", "Up", "Down");
	ship.setInput(input);

func reqSwitch(): 
	# Payload
	var packet: Dictionary = {
		&"name": parent.name,
	}
	Manager.reqCamList.emit(packet);
