extends State;

func Entry() -> void:
	# Connect Signal 
	if (not Manager.driverExit.is_connected(handleExit)):
		Manager.driverExit.connect(handleExit);

	# Player setup
	parent.position = Vector2.ZERO;
	parent.setPlayerSkin(parent.SkinType.BOAT);

func Exit() -> void:
	# Disconnect Signal 
	if Manager.driverExit.is_connected(handleExit):
		Manager.driverExit.disconnect(handleExit);
	
	parent.setPlayerSkin(parent.SkinType.SKIN);

func HandleInput(_e: InputEvent) -> void:
	if _e.is_action_pressed("CameraSwitch"): reqSwitch();
	
func handleExit(packet: Dictionary) -> void:
	if packet[&"vehicle"] != &"Ship": return;
	if packet[&"driver"] != parent.name: return;
	# Handle player ship
	stateManager.changeState(stateManager.States.IDLE);

func reqSwitch(): 
	# Payload
	var packet: Dictionary = {&"name": parent.name}
	Manager.reqCamList.emit(packet);
