extends CanvasLayer

onready var global_vars = get_node("/root/Global")


onready var name_input = $Control/Panel/NameInput
onready var color_input = $Control/Panel/NameInput/NameColor
onready var skin_selector = $Control/Panel/SkinSelector

export var skins = []

func _ready():
	skin_selector.select(0)
	get_node("/root/Global").player_info = {
		name =  name_input.text,
		color = color_input.color.to_html(),
		skin = skins[skin_selector.get_selected_items()[0]]
	}


func start_game():
	get_node("/root/Global").world_seed = int($Control/Panel/SeedInput.text)
	get_node("/root/Global").player_info = {
		name =  name_input.text,
		color = color_input.color.to_html(),
		skin = skins[skin_selector.get_selected_items()[0]]
	}
	var _s = get_tree().change_scene("res://Level.tscn")


func _on_play_button_pressed():
	start_game()

func _on_exit_button_pressed():
	get_tree().quit()
