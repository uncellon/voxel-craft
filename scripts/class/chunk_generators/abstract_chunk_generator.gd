class_name AbstractChunkGenerator
extends Resource

################################################################################
# Methods                                                                      #
################################################################################

func get_block_id(_block_pos: Vector3i) -> BlockDatabase.Id:
	return BlockDatabase.Id.AIR
