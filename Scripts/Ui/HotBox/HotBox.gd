extends NinePatchRect;

# Signal 
signal slotPressed(packet: Dictionary);

# Lazy Load
@onready var holder: HBoxContainer = $Center/Holder;

# Variables
var hotBoxData: Dictionary = {};
var slots: Array[Node] = [];
var players: Dictionary[StringName, Dictionary] = {};

func _ready() -> void:
	# Lambda Signal 
	Manager.playerIdle.connect(func(packet: Dictionary):
		# Check in cached players
		if not players.is_empty():
			if packet[&"name"] in players.keys():
				clearHotBox();
				setHotBox(players[packet[&"name"]]);
			else:
				if not hotBoxData.is_empty():
					players[packet[&"name"]] = hotBoxData;
				else:
					players[packet[&"name"]] = {};

				clearHotBox();
				setHotBox(players[packet[&"name"]]);

		else:
			if not hotBoxData.is_empty():
				players[packet[&"name"]] = hotBoxData;
			else:
				players[packet[&"name"]] = {};

			clearHotBox();
			setHotBox(players[packet[&"name"]]);

		print(players);
	)

func clearHotBox() -> void:
	# Clear slots
	slots = holder.get_children();
	# Slots Exits
	if not slots.is_empty():
		# Loop over slots
		for slot in slots:
			# Handle type
			if slot is TextureButton:
				# Hide slot
				if slot.has_method("hideItem"): slot.hideItem(true);

func setHotBox(data: Dictionary) -> void:
	# Refactor Data
	if not data.is_empty():
		hotBoxData = data;
	else: hotBoxData = GameResource.weaponsRef.hotbox;

	# Setup slots
	if not slots.is_empty():
		# Loop and fill
		for index in range(hotBoxData.size()):
			# Handle type
			if slots[index] is TextureButton:
				var slot = slots[index];
				# Fill slot
				if slot.has_method("fillSlot") and slot.has_method("hideItem")\
					and slot.has_method("setTexture") and slot.has_method("setItemName"):					
					# Set default 
					if index == 0 and slot.has_method("handleClick"): slot.handleClick();
					# Set slef 
					slot.hotbox = self;
					# Connect signal 
					if slot.has_method("resetSelf"):
						if not slotPressed.is_connected(slot.resetSelf):
							slotPressed.connect(slot.resetSelf);
					# Set properties
					var itemName = hotBoxData.keys()[index];
					slot.setItemName(itemName);
					slot.setTexture(GameResource.getTexture(itemName));
					slot.fillSlot(hotBoxData.values()[index]); 
					slot.hideItem(false);