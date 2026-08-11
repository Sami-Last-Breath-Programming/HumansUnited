extends State;

# Variables
var ship: CharacterBody2D;

func Entry() -> void:
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