extends KinematicBody2D

# Player movement variables
export var speed = 1500
export var jump = 1000
export var gravity = 2000
export var velocity = Vector2(0, 0)
var gravity_on = true
onready var jetpackparticles = $jetpackparticles

export var items = []
var currently_selected = null
onready var jump_sfx = $"jump sfx"

# Jetpack variables
export var jetpack_force = 500  # Upward force applied by the jetpack
export var max_fuel = 500.0  # Maximum fuel for the jetpack
export var fuel_consumption_rate = 10.0  # Fuel consumed per second
export var fuel_recharge_rate = 5.0  # Fuel recharged per second when on the ground
var current_fuel = max_fuel
var jetpack_active = false
export var chunks = Vector2(0, 0)
export var defaultSkin = "res://Skins/GodotSkin.tscn"
var skin = null

onready var fuel = $PlayerUI/fuel
onready var console = $UI/Console


func _ready():
	jetpackparticles.emitting = false

func init(player_name, selected_skin, name_color):
	$"%PlayerName".text = str(player_name)
	$"%PlayerName".self_modulate = Color(name_color)
	
	# Ensure selected_skin is a valid before attempting to instance it
	if selected_skin != "":
		skin = load(selected_skin).instance()
	else:
		if defaultSkin:
			skin = load(defaultSkin).instance()
		else:
			print("Error: No valid skin provided.")
			return  # Exit if no skin is available

	add_child(skin)
	

func get_item_text():
	return str(items)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not console.visible:
		handle_control(delta)
	handle_console()

func handle_console():
	if Input.is_action_just_released("toggle_console"):
		console.toggle()

func handle_control(delta):
	fuel.max_value = int(max_fuel)
	fuel.value = int(current_fuel) 
	handle_movement(delta)
	handle_gravity(delta)
	handle_jump(delta)
	handle_jetpack(delta)
	handle_gravity_toggle()
	var _v = move_and_slide(velocity, Vector2.UP)
	# Update the jetpack fuel progress bar
	fuel.value = int(current_fuel)


func handle_movement(_delta):
	# Movement left/right
	velocity.x = Input.get_axis("left", "right") * int(speed)
	if Input.is_action_pressed("go_to_origin"):
		self.position = Vector2(0, 0)

func handle_gravity(delta):
	if not is_on_floor() and gravity_on:
		velocity.y += gravity * delta

func handle_jump(_delta):
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -int(jump)
		jump_sfx.play()

func handle_jetpack(delta):
	if Input.is_action_pressed("jetpack") and int(current_fuel) > 0:
		activate_jetpack(delta)
		jetpackparticles.emitting = true
	else:
		deactivate_jetpack(delta)
		jetpackparticles.emitting = false

func activate_jetpack(delta):
	if int(current_fuel) > 0:
		jetpack_active = true
		velocity.y = -int(jetpack_force)  # Apply upward force
		current_fuel -= int(fuel_consumption_rate) * delta  # Decrease fuel while jetpack is active
		current_fuel = max(int(current_fuel), 0)  # Ensure fuel doesn't go below 0

func deactivate_jetpack(delta):
	jetpack_active = false
	if is_on_floor():
		# Recharge fuel while on the ground
		current_fuel = min(int(max_fuel), int(current_fuel) + int(fuel_recharge_rate) * delta)

func handle_gravity_toggle():
	if Input.is_action_pressed("q"):
		gravity_on = !gravity_on

func get_chunk_from_position(pos):
	return Vector2(floor(pos.x / (16 * 16 * 4)), floor(pos.y / (16 * 16 * 4)))
