extends State

# Variables
var driver: CharacterBody2D;

func Entry() -> void:
	# Driver Exist
	driver = parent.getDriver();
	# Set Driver False
	if (driver): driver.visible = false;

func Exit() -> void:	
	# Driver Exist
	driver = parent.getDriver();
	# Set Driver true
	if (driver): driver.visible = true;
