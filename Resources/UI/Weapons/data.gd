class_name Weapons
extends Resource;

var textures: Dictionary[StringName, String] = {
	&"Log": "res://Assets/Items/Log.png",
	&"Axe": "res://Assets/Items/Axe_Stone.png",
	&"Hammer": "res://Assets/Items/Hammer.png",
	&"PickAxe": "res://Assets/Items/PickAxe.png",
}

var weapons: Dictionary[StringName, String] = {
	&"Log": "",
	&"Axe": "res://Scenes/Interactives/Weapons/Axe.tscn",
	&"Hammer": "res://Scenes/Interactives/Weapons/Hammer.tscn",
	&"PickAxe": "",
}

# Item: Amount, Health
var hotbox: Dictionary[StringName, Array] = {
	&"Axe": [1, 100.0],
	&"Hammer": [2, 100.0],
	&"Log": [16, -1.0],
	&"PickAxe": [1, 100.0],
}