class_name ShipData
extends Resource;

# Paths to the ship skins
var skins: Dictionary = {
	0: 	["res://Assets/Ships/Sprites/Ship1.png",
		"res://Assets/Ships/Sprites/Ship2.png",
		"res://Assets/Ships/Sprites/Ship3.png",
		 null, [8.0, 28.0, [0.0, 0.0]], 0.9],
	1:	["res://Assets/Ships/Sprites/Ship7.png", 
		"res://Assets/Ships/Sprites/Ship13.png",
		"res://Assets/Ships/Sprites/Ship19.png",
		"res://Assets/Ships/Sprites/Ship25.png",
		[11.0, 50.0, [0.0, 0.4]], 0.5],
	2:	["res://Assets/Ships/Sprites/Ship12.png",
		"res://Assets/Ships/Sprites/Ship18.png",
		"res://Assets/Ships/Sprites/Ship24.png",
		"res://Assets/Ships/Sprites/Ship30.png",
		[12.0, 70.0, [0.0, 1.0]], 0.6],
	3:	["res://Assets/Ships/Sprites/Ship9.png", 
		"res://Assets/Ships/Sprites/Ship15.png",
		"res://Assets/Ships/Sprites/Ship21.png",
		"res://Assets/Ships/Sprites/Ship27.png",
		[17.0, 94.0, [0.0, 1.0]], 0.8],
	4:	["res://Assets/Ships/Sprites/Ship8.png",
		"res://Assets/Ships/Sprites/Ship14.png",
		"res://Assets/Ships/Sprites/Ship20.png",
		"res://Assets/Ships/Sprites/Ship26.png",
		[18.0, 100.0, [0.0, 1.0]], 0.9],
};

# Skins having top roof
var roofs: Array = [1, 2, 3, 4];
