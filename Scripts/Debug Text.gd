extends Label
onready var player = $"../.."

# List of additional properties to display
export var extra_properties = ["player_name_color"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func toggle():
	pause_mode = !pause_mode
	visible = !visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var display_text = ""
	
	# Get and display all properties of the player
	var props = player.get_property_list()
	for prop in props:
		if prop.type in [TYPE_REAL, TYPE_INT, TYPE_STRING, TYPE_BOOL, TYPE_VECTOR2, TYPE_COLOR]:
			display_text += prop.name + " : " + str(player.get(prop.name)) + "\n"
	
	# Display additional specified properties
	for extra_prop in extra_properties:
		# Try to get the property value and handle the case if it doesn't exist
		if extra_prop in props:
			display_text += extra_prop + " : " + str(player.get(extra_prop)) + "\n"
		else:
			display_text += extra_prop + " : N/A\n"  # Indicate that the property is not available

	text = display_text.strip_edges()  # Remove any extra whitespace
