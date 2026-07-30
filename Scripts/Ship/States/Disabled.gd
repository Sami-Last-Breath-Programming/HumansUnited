extends State

# Variables
var ship = parent as CharacterBody2D;
var driver: CharacterBody2D;

func Entry() -> void:
	# Driver Exist
	driver = ship.getDriver();
	# Set Driver False
	if (driver): driver.visible = false;

func Exit() -> void:	
	# Driver Exist
	driver = ship.getDriver();
	# Set Driver true
	if (driver): driver.visible = true;
