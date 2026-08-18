extends Node

# Signal
signal addItem(packet: Dictionary);
signal removeItem(packet : Dictionary); 

# Variables
var weaponsRef: Weapons = Weapons.new();
var weapons: Dictionary;
var weaponTextures: Dictionary;
var dataBase: Dictionary[StringName, Dictionary];

func _ready() -> void:
	# Connect Signals
	addItem.connect(addItemToDataBase);
	removeItem.connect(removeItemFromDataBase);
	# Ref weapons
	weapons = weaponsRef.weapons;
	weaponTextures = weaponsRef.textures;

func addItemToDataBase(packet: Dictionary) -> void: 
	print("Item Added to DataBase: ", packet[&"name"]);
	dataBase[packet[&"name"]] = packet[&"data"];
	print_rich(dataBase);

func removeItemFromDataBase(packet: Dictionary) -> void:
	print("Item Removed from DataBase: ", packet[&"name"]);
	dataBase.erase(packet[&"name"])
	print_rich(dataBase);

func getTexture(wName: StringName) -> Texture:
	var res: String = weaponTextures.get(wName, "");
	# Load the weapon texture
	if not res.is_empty():
		var loaded = load(res);
		return loaded as Texture;
	else: return null;