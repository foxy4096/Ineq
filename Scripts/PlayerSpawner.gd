extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player:PackedScene = load("res://Prefabs/Player.tscn")
export var skin:PackedScene = preload("res://Prefabs/defaultSkin.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_instance = player.instance()
	player_instance.skin = skin
	add_child_below_node($"..", player_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
