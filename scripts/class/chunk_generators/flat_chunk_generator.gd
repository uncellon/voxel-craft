@tool
class_name FlatChunkGenerator
extends AbstractChunkGenerator

################################################################################
# Methods                                                                      #
################################################################################

func get_block_id(block_pos: Vector3i) -> BlockDatabase.Id:
	if block_pos.y < 1:
		return BlockDatabase.Id.GRASS
	return BlockDatabase.Id.AIR
