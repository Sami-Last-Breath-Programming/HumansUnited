extends State

# Variables
var driver: CharacterBody2D;

func Entry() -> void:
	# Driver Exist
	driver = parent.getDriver();
	# Set Driver as Child
	if (driver):
		driver.reparent(parent);
		driver.global_position = parent.global_position;
		# Set Driver False
		if parent.hasRoof():
			driver.visible = false;

func Exit() -> void:	
	# Driver Exist
	driver = parent.getDriver();
	# Set Driver true
	if (driver): 
		driver.visible = true;
		driver.reparent(get_tree().current_scene);
