extends TextureButton;

# Lazy Load 
@onready var item: TextureRect = $Item;
@onready var amount: Label = $Amount;
@onready var health: TextureProgressBar = $Health;
@onready var anim: AnimationPlayer = $Anim;

# Variables
var itemName: StringName = &"";
var hotbox: NinePatchRect = null;

func handleClick() -> void:
	# Set Active
	self.set_pressed_no_signal(true);
	health.visible = true;
	# Set Anim
	anim.play("active");
	# Emit signal 
	if hotbox: hotbox.slotPressed.emit({
		&"name": self.name,
		&"itemName": self.itemName,
	})

func resetSelf(packet: Dictionary) -> void:
	# Check who 
	if (packet[&"name"] != self.name):
		# Set Default
		self.set_pressed_no_signal(false);
		health.visible = false;
		# Set Anim
		anim.play("default");

func hideItem(flag: bool) -> void:
	if flag:
		if not self.disabled: self.disabled = true;
		if item.visible: item.visible = false;
		if amount.visible: amount.visible = false;
	else:
		if self.disabled: self.disabled = false;
		if not item.visible: item.visible = true;
		if not amount.visible: amount.visible = true;

func fillSlot(data: Array) -> void:
	if not data.is_empty(): 
		amount.text = str(data[0]);
		health.max_value = data[1];
		health.value = data[1];

func setItemName(iName: StringName) -> void:
	if not name.is_empty(): itemName = iName;

func setTexture(tex: Texture) -> void:
	if tex: item.texture = tex;
