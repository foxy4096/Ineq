extends TileMap

const GRASS = 0
const DIRT = 1
const STONE = 2  # Assuming 2 is the tile ID for stone
const CAVE_THRESHOLD = -0.1  # Noise threshold for caves

onready var noise := OpenSimplexNoise.new()

export var temperature = 0.5
export var chunk_size = 16  # Same chunk size as in the level script

var modified_chunks = {}

# Generate a single chunk based on its chunk position (chunk_x, chunk_y)
func generate_chunk(chunk_position):
	var global_vars = get_node("/root/Global")
	noise.seed = global_vars.world_seed
	
	var chunk_x = chunk_position.x * chunk_size
	var chunk_y = chunk_position.y * chunk_size
	
	# Surface generation
	for x in range(chunk_x, chunk_x + chunk_size):
		var ground = abs(noise.get_noise_2d(x, 0) * 12 * temperature * 5)
		for y in range(ground, chunk_y + chunk_size):
			if noise.get_noise_2d(x, y) > -temperature:
				if get_cell(x, y - 1) == -1:
					set_cell(x, y, GRASS)
				else:
					set_cell(x, y, DIRT)
					
	modified_chunks[chunk_position] = get_chunk_state(chunk_position)
	
func get_chunk_state(chunk_position):
	var chunk_state = []
	var chunk_x = chunk_position.x * chunk_size
	var chunk_y = chunk_position.y * chunk_size
	
	for x in range(chunk_x, chunk_x + chunk_size):
		var column = []
		for y in range(chunk_y, chunk_y + chunk_size):
			column.append(get_cell(x, y))
		chunk_state.append(column)
	return chunk_state
	
func apply_modified_chunks():
	for chunk_pos in modified_chunks.keys():
		var chunk_state = modified_chunks[chunk_pos]
		var chunk_x = chunk_pos.x * chunk_size
		var chunk_y = chunk_pos.y * chunk_size
		
		for x in range(chunk_x, chunk_x + chunk_size):
			for y in range(chunk_y, chunk_y + chunk_size):
				if y < chunk_state.size() and x < chunk_state[y].size():
					set_cell(x, y, chunk_state[y][x])

func remove_chunk(chunk_position):
	var chunk_x = chunk_position.x * chunk_size
	var chunk_y = chunk_position.y * chunk_size
	for x in range(chunk_x, chunk_x + chunk_size):
		for y in range(chunk_y, chunk_y + chunk_size):
			set_cell(x, y, -1)


func get_chunk_from_position(pos):
	return Vector2(floor(pos.x / (chunk_size * chunk_size * 4)), floor(pos.y / (chunk_size * chunk_size * 4)))

