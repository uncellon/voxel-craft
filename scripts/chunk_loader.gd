class_name ChunkLoader
extends RefCounted

@export var chunk_create_strategy: Callable
@export var workers_count = 8 # How many threads will load chunks
@export var thread_chunks_chunk_limit = 4 # How many chunks thread will load per loop

var threads: Array[Thread]
var is_running = true
var sem = Semaphore.new()

var chunk_positions_to_load = []
var chunk_poss_to_load_mtx = Mutex.new()

var loaded_chunks = []
var loaded_chunks_mtx = Mutex.new()

var chunk_poss_to_load_locals = [] # Array of array

func _init() -> void:
	threads.resize(workers_count)
	chunk_poss_to_load_locals.resize(workers_count)

	for i in workers_count:
		chunk_poss_to_load_locals[i] = []
		threads[i] = Thread.new()
		threads[i].start(loop.bind(i))

	# !!! For-each in this scenario causes memory leak !!!
	# for thread in threads:
	# 	thread = Thread.new()
	# 	thread.start(loop)

func _exit_tree() -> void:
	is_running = false
	sem.post(workers_count)
	for thread in threads:
		thread.wait_to_finish()

func push_chunk_positions_to_load(new_chunk_positions_to_load: Array):
	loaded_chunks_mtx.lock()
	chunk_poss_to_load_mtx.lock()

	# Check every chunk position in already prepared and loaded chunks
	for chunk_poss_to_load_local in chunk_poss_to_load_locals:
		for chunk_position in chunk_poss_to_load_local: # Currently processing queue
			if new_chunk_positions_to_load.has(chunk_position):
				new_chunk_positions_to_load.erase(chunk_position)
	for chunk_position in chunk_positions_to_load: # Queue to process
		if new_chunk_positions_to_load.has(chunk_position):
			new_chunk_positions_to_load.erase(chunk_position)
	for chunk in loaded_chunks: # Loaded chunks
		if new_chunk_positions_to_load.has(chunk.chunk_position):
			new_chunk_positions_to_load.erase(chunk.chunk_position)

	chunk_positions_to_load.append_array(new_chunk_positions_to_load)

	chunk_poss_to_load_mtx.unlock()
	loaded_chunks_mtx.unlock()
	sem.post(workers_count)

func has_loaded_chunks() -> bool:
	loaded_chunks_mtx.lock()
	var result = !loaded_chunks.is_empty()
	loaded_chunks_mtx.unlock()
	return result

func get_loaded_chunks() -> Array:
	loaded_chunks_mtx.lock()
	var tmp = loaded_chunks.duplicate()
	loaded_chunks.clear()
	loaded_chunks_mtx.unlock()
	return tmp

func loop(index: int) -> void:
	var loaded_chunks_local = []

	while is_running:
		sem.wait()

		# Copy "chunk positions to load" to local version to minimize mutex block
		chunk_poss_to_load_mtx.lock()

		var slice_end = thread_chunks_chunk_limit
		if slice_end > chunk_positions_to_load.size():
			slice_end = chunk_positions_to_load.size()
		#print(str("Before: ", chunk_positions_to_load))
		chunk_poss_to_load_locals[index] = chunk_positions_to_load.slice(0, slice_end)
		chunk_positions_to_load = chunk_positions_to_load.slice(slice_end)
		#print(str("Slice: ", chunk_poss_to_load_locals[index]))
		#print(str("Remains: ", chunk_positions_to_load))

		chunk_poss_to_load_mtx.unlock()

		if chunk_poss_to_load_locals[index].size() == 0:
			continue

		# Loading
		for chunk_position_to_load in chunk_poss_to_load_locals[index]:
			loaded_chunks_local.append(chunk_create_strategy.call(chunk_position_to_load))

		# Copy loaded chunks into output queue
		loaded_chunks_mtx.lock()
		loaded_chunks.append_array(loaded_chunks_local)
		loaded_chunks_mtx.unlock()
		loaded_chunks_local.clear()
