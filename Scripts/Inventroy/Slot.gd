extends TextureRect;

# Lazy Load 
@onready var popUp: ProtonControlAnimation = $PopUp;

# Variables
var inventory: Button;
var delayTime: float;
var slotQueueTime: float;

func _ready() -> void:
	# Ref root
	inventory = owner;
	# Set Properties
	self.visible = false;
	slotQueueTime = 10.0;
	# Connect signal 
	if inventory:
		inventory.AnimSlots.connect(showSlotAnim);
		inventory.RestSlotsColor.connect(resetColor)
		# Setup delay 
		delayTime = float(self.get_index()) / slotQueueTime;
		# Set delay
		popUp.delay = delayTime;

func showSlotAnim() -> void:
	self.visible = false;
	popUp.start();
	self.visible = true;

func resetColor() -> void:
	self.modulate = Color(1.0, 1.0, 1.0, 0.0);