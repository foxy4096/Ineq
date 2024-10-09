extends LineEdit

onready var player = $"../.."
onready var player_collider = $"%player collider"
onready var debug_text = $"%Debug Text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func toggle():
		pause_mode = !pause_mode
		visible = !visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	grab_focus()

func _on_Console_text_entered(new_text):
	var tokens = new_text.split(" ")
	if new_text == "exit":
		get_tree().quit()
	elif tokens.size() > 0:
		var command = tokens[0]
		if command == "goto":
			if tokens.size() == 3:
				var x = int(tokens[1])  # Convert to int safely
				var y = int(tokens[2])  # Convert to int safely
				player.position = Vector2(x, y)
			else:
				player.position = Vector2(0, 0)

		elif new_text == "stuck":
			player.position = Vector2(-100, -100)
		
		elif command == "player" and tokens.size() == 3:
			var key = tokens[1]
			var value = tokens[2]

			# Check if the property exists
			var property_list = player.get_property_list()
			for prop in property_list:
				if prop.name == key:
					player.set(key, value)
			print("Invalid property: " + key)  # Property doesn't exist
		elif command == "debug":
			debug_text.toggle()
		elif command == "noclip":
			player.velocity = Vector2(0, 0)
			player_collider.disabled = !player_collider.disabled
			player.gravity_on = !player.gravity_on

	text = ""  # Clear the text input
	toggle()
