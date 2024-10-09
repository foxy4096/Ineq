extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var is_animated = false
export var idle_anim = ""
export var run_anim = ""
export var jump_anim = ""
onready var animated_sprite = $"%AnimatedSprite"
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
		
	if Input.is_action_pressed("left"):
		direction = -1
	elif Input.is_action_pressed("right"):
		direction = 1
		
	if direction == -1:
		animated_sprite.flip_h = true
	elif direction == 1:
		animated_sprite.flip_h = false

