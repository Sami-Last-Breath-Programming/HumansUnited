extends State;

# Variables
var ship: CharacterBody2D;

func Entry() -> void:
	# Check metaData
	if parent.metaData[&"inVehicle"]:
		if parent.metaData[&"vehicleType"] == &"Ship":
			# Set water skin
			if parent.has_method("setPlayerSkin"):
				parent.setPlayerSkin(parent.SkinType.BOAT);
	
	# Set metaData 
	parent.metaData[&"state"] = self.name;
	parent.collider.call_deferred("set_disabled", false);

	# Connect signal
	if (not Manager.cameraSwitched.is_connected(updateMetaData)):
		Manager.cameraSwitched.connect(updateMetaData);

func updateMetaData(packet: Dictionary) -> void:
	# Check if self request
		if packet[&"lastPlayerName"] == parent.name:
			parent.metaData[&"isSwiching"] = false;

func Exit() -> void:
	# Disconnect signal
	if (Manager.cameraSwitched.is_connected(updateMetaData)):
		Manager.cameraSwitched.disconnect(updateMetaData);
	
	parent.collider.call_deferred("set_disabled", true); 