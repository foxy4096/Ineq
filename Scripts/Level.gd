extends Node2D

export var chunk_size = 16  # Adjust this for chunk size
export var max_active_chunks = 9  # Maximum chunks loaded around the player
export var far = 16
var active_chunks = {}  # Dictionary to track active chunks with their coordinates

var player_position = Vector2()
onready var level = $"."
onready var players_group = $players_group

var current_player = null

onready var level_generator = $"%LevelGenerator"



func _ready():
	spawn_player()
	update_active_chunks(player_position)

func spawn_player():
	var new_player = preload("res://Prefabs/Player.tscn").instance()
	var info = get_node("/root/Global").player_info
	new_player.name = info.name
	current_player = new_player
	players_group.add_child(new_player)
	new_player.init(info.name, info.skin, info.color)
	player_position = new_player.position
	

# Called every physics frame
func _physics_process(_delta):
	update_chunk()


# -- CHUNK LOADING SYSTEM BEGIN

func update_chunk():
	if get_chunk_from_position(current_player.position) != get_chunk_from_position(player_position):
		player_position = current_player.position
		update_active_chunks(player_position)
# Update active chunks based on player position
func update_active_chunks(player_pos):
	var current_chunk = get_chunk_from_position(player_pos)

	# Load chunks in the 3x3 grid around the player
	for x in range(current_chunk.x - 1, current_chunk.x + 2):
		for y in range(current_chunk.y - 1, current_chunk.y + 2):
			var chunk_pos = Vector2(x, y)
			if not active_chunks.has(chunk_pos):
				load_chunk(chunk_pos)

	# Unload chunks that are too far away from the player
	unload_distant_chunks(current_chunk)

# Convert a world position to a chunk position
func get_chunk_from_position(pos):
	return Vector2(floor(pos.x / (chunk_size * chunk_size * 4)), floor(pos.y / (chunk_size * chunk_size * 4)))

# Load a chunk at a specific position
func load_chunk(chunk_pos):
	# Add chunk to active chunks
	active_chunks[chunk_pos] = true
	# Here you can generate tiles or objects for the chunk
	level_generator.generate_chunk(chunk_pos)

# Unload chunks that are far away
func unload_distant_chunks(current_chunk):
	var chunks_to_remove = []
	
	for chunk_pos in active_chunks.keys():
		if chunk_pos.distance_to(current_chunk) > far:  # Modify distance threshold as necessary
			chunks_to_remove.append(chunk_pos)

	for chunk_pos in chunks_to_remove:
		unload_chunk(chunk_pos)

# Unload a chunk
func unload_chunk(chunk_pos):
	active_chunks.erase(chunk_pos)
	level_generator.remove_chunk(chunk_pos)

# -- CHUNK LOADING SYSTEM END --

# Handling mouse input to add or remove tiles
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:  # Left mouse button to add tile
			add_tile_at_mouse_position()
		elif event.button_index == BUTTON_LEFT and event.pressed:  # Right mouse button to remove tile
			remove_tile_at_mouse_position()

func apply_modified_chunks():
	for chunk_pos in level_generator.modified_chunks.keys():
		if level_generator.modified_chunks[chunk_pos]:
			var chunk_state = level_generator.get_chunk_state(chunk_pos)
			var chunk_x = chunk_pos.x * level_generator.chunk_size
			var chunk_y = chunk_pos.y * level_generator.chunk_size
			
			for x in range(chunk_x, chunk_x + level_generator.chunk_size):
				for y in range(chunk_y, chunk_y + level_generator.chunk_size):
					if y < chunk_state.size() and x < chunk_state[y].size():
						level_generator.set_cell(x, y, chunk_state[y][x])

	# After applying, you can clear the modified chunks
	level_generator.modified_chunks.clear()


# Add tile at mouse position
func add_tile_at_mouse_position():
	var mouse_pos = get_global_mouse_position()
	var cell_pos = level_generator.world_to_map(mouse_pos)  # Convert mouse position to cell position
	if level_generator.get_cellv(cell_pos) == -1 and current_player.items.size() != 0:
		# Set the tile and mark the chunk as modified
		level_generator.set_cellv(cell_pos, current_player.items[0])  # Change to the desired tile type
		current_player.items.pop_front()
		# Update modified chunks
		var chunk_pos = level_generator.get_chunk_from_position(cell_pos)
		level_generator.modified_chunks[chunk_pos] = true  # Mark chunk as modified

# Remove tile at mouse position
func remove_tile_at_mouse_position():
	var mouse_pos = get_global_mouse_position()
	var cell_pos = level_generator.world_to_map(mouse_pos)  # Convert mouse position to cell position
	if(level_generator.get_cellv(cell_pos) != -1):
		current_player.items.append(level_generator.get_cellv(cell_pos))
		level_generator.set_cellv(cell_pos, -1)  # Set to -1 to remove the tile
		# Update modified chunks
		var chunk_pos = level_generator.get_chunk_from_position(cell_pos)
		level_generator.modified_chunks[chunk_pos] = true  # Mark chunk as modified

# For going to Menu Screen
func _on_back_button_pressed():
	queue_free()
	var _t = get_tree().change_scene("res://Menu.tscn")
