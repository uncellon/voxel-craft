extends Node3D

@export var radius: int = 4
@export var player: CharacterBody3D
@export var chunk_generator: AbstractChunkGenerator

var player_chunk_pos: Vector2i
var loaded_chunks: Dictionary
var chunk_loader = ChunkLoader.new()

var chunk_create_strategy = func(chunk_position: Vector2i) -> Chunk:
	var chunk = Chunk.new()
	chunk.chunk_position = chunk_position
	chunk.chunk_generator = chunk_generator
	chunk.fill_and_draw_RENAME_THIS()
	return chunk

func _ready() -> void:
	player_chunk_pos = get_current_player_chunk_pos()
	chunk_loader.chunk_create_strategy = chunk_create_strategy

	# Load only one chunk where the player is located
	var player_chunk = chunk_create_strategy.call(player_chunk_pos)
	loaded_chunks[player_chunk_pos] = player_chunk
	add_child(player_chunk)

	load_chunks_at_player()

	# Check that player not stuck in current position
	# This is temporary method because player can stuck in between X and Z axis
	for y in range(player_chunk_pos.y, Chunk.DIMENSIONS.y):
		if player_chunk.is_solid(Vector3i(
			player.position.x - player_chunk_pos.x * Chunk.DIMENSIONS.x,
			y,
			player.position.z - player_chunk_pos.y * Chunk.DIMENSIONS.z
		)) or player_chunk.is_solid(Vector3i(
			player_chunk_pos.x * Chunk.DIMENSIONS.x + player.position.x,
			y + 1,
			player_chunk_pos.y * Chunk.DIMENSIONS.z + player.position.z,
		)):
			continue
		player.position.y = y + 1
		break

func _process(_delta: float) -> void:
	var new_player_chunk_pos = get_current_player_chunk_pos()
	if new_player_chunk_pos != player_chunk_pos or chunk_loader.has_loaded_chunks():
		player_chunk_pos = new_player_chunk_pos
		unload_distant_chunks()
		load_chunks_at_player()

func get_current_player_chunk_pos() -> Vector2i:
	var pcp = floor(player.position / Chunk.DIMENSIONS.x)
	return Vector2i(pcp.x, pcp.z)

func load_chunks_at_player() -> void:
	var new_chunk_positions = []
	var radius_squared = radius * radius

	for r in range(1, radius + 1):
		for x in range(-r, r + 1):
			for y in range(-r, r + 1):
				if abs(x) != r and abs(y) != r:
					continue # Skip internal points
				var chunk_pos = player_chunk_pos + Vector2i(x, y)
				if not loaded_chunks.has(chunk_pos) and (chunk_pos - player_chunk_pos).length_squared() <= radius_squared:
					new_chunk_positions.append(chunk_pos)

	chunk_loader.push_chunk_positions_to_load(new_chunk_positions)

	# Read loaded chunks by thread
	var new_loaded_chunks = chunk_loader.get_loaded_chunks()
	for new_loaded_chunk in new_loaded_chunks:
		# Filter outdated (distant) chunks
		if (player_chunk_pos - new_loaded_chunk.chunk_position).length() > radius:
			new_loaded_chunk.queue_free()
			continue

		loaded_chunks[new_loaded_chunk.chunk_position] = new_loaded_chunk
		add_child(new_loaded_chunk)

func unload_distant_chunks() -> void:
	var loaded_chunk_poss: Array = loaded_chunks.keys()

	for chunk_pos in loaded_chunk_poss:
		if (chunk_pos - player_chunk_pos).length() > radius:
			loaded_chunks[chunk_pos].queue_free()
			loaded_chunks.erase(chunk_pos)
