extends State;

func Entry() -> void:
	# Connect Signal 
	if (not Manager.driverExit.is_connected(handleExit)):
		Manager.driverExit.connect(handleExit);
	
	# Connect Lambda Signal
	Manager.cameraSwitching.connect(func(packet: Dictionary):
		# Check if self request
		if packet[&"lastPlayerName"] == parent.name:
			stateManager.changeState(stateManager.States.DISABLED),
		
		CONNECT_ONE_SHOT	
	)

	# Set metaData 
	parent.metaData[&"state"] = self.name;
	parent.metaData[&"inVehicle"] = true;
	parent.metaData[&"vehicleType"] = &"Ship";
	parent.metaData[&"vehicleId"] = parent.getVehicle().get_instance_id();

	# Signal to Manager
	var mainCamera = Manager.getMainCamera();
	var vehical = parent.getVehicle();
	# Exist
	if vehical and mainCamera:
		var packet: Dictionary = {
			&"vehicleId": vehical.get_instance_id(),
			&"vehiclePos": vehical.global_position,
		}
		var packet2: Dictionary = {
			&"vehicle": &"Ship",
			&"vehicleDamaged": vehical.damageSpeedApplied,
		}
		# Signal to camera
		if mainCamera: mainCamera.playerVehicleActive.emit(packet);
		# Signal to hud
		Manager.driverEnter.emit(packet2);  

	# Player setup
	parent.playerName.visible = false;
	parent.position = Vector2.ZERO;
	parent.setPlayerSkin(parent.SkinType.BOAT);

func Exit() -> void:
	# Disconnect Signal 
	if Manager.driverExit.is_connected(handleExit):
		Manager.driverExit.disconnect(handleExit);
	
	parent.playerName.visible = true;
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

	# Handle Animation 
	if (input != Vector2.ZERO):
		handleAnim(input);

func handleAnim(input: Vector2) -> void:
	if abs(input.x) > abs(input.y):
		# Check Horizontal
		if input.x > 0.1:
			parent.animManager.play("idle_right");
		elif input.x < -0.1:
			parent.animManager.play("idle_left");
	else:
		# Check Vertical
		if input.y > 0.1:
			parent.animManager.play("idle_down");
		elif input.y < -0.1:
			parent.animManager.play("idle_up");

func reqSwitch(): 
	# Update metaData
	parent.metaData[&"isSwiching"] = true;
	
	# Payload
	var packet: Dictionary = {
		&"name": parent.name,
	}
	Manager.reqCamList.emit(packet);
