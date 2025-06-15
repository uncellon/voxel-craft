@tool
class_name PerlinNoiseChunkGenerator
extends AbstractChunkGenerator

################################################################################
# Constants                                                                    #
################################################################################

const NOISE_FACTOR = 8

################################################################################
# Members                                                                      #
################################################################################

var noise = FastNoiseLite.new()

################################################################################
# Methods                                                                      #
################################################################################

func get_block_id(block_pos: Vector3i) -> BlockDatabase.Id:
	var current_noise = 1 + NOISE_FACTOR + noise.get_noise_2d(block_pos.x, block_pos.z) * NOISE_FACTOR
	if block_pos.y < current_noise:
		return BlockDatabase.Id.GRASS
	return BlockDatabase.Id.AIR
