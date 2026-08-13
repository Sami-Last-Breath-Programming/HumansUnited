extends Node

# Signal
signal addItem(packet: Dictionary);
signal removeItem(packet : Dictionary); 

# Variables
var dataBase: Dictionary[StringName, Dictionary];

func _ready() -> void:
	# Connect Signals
	addItem.connect(addItemToDataBase);
	removeItem.connect(removeItemFromDataBase);

func addItemToDataBase(packet: Dictionary) -> void: 
	print("Item Added to DataBase: ", packet[&"name"]);
	dataBase[packet[&"name"]] = packet[&"data"];
	print_rich(dataBase);

func removeItemFromDataBase(packet: Dictionary) -> void:
	print("Item Removed from DataBase: ", packet[&"name"]);
	dataBase.erase(packet[&"name"])
	print_rich(dataBase);


