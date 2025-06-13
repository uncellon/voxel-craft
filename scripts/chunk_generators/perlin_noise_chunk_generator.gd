@tool
class_name PerlinNoiseChunkGenerator extends AbstractChunkGenerator

const NOISE_FACTOR = 16

var noise = FastNoiseLite.new()

func get_block_id(block_pos: Vector3i) -> BlocksDictionary.Id:
	var current_noise = 1 + NOISE_FACTOR + noise.get_noise_2d(block_pos.x, block_pos.z) * NOISE_FACTOR
	if block_pos.y < current_noise:
		return BlocksDictionary.Id.GRASS
	return BlocksDictionary.Id.AIR
