class_name FlatChunkGenerator extends AbstractChunkGenerator

func get_block_id(block_pos: Vector3i) -> BlocksDictionary.Id:
	if block_pos.y < 1:
		return BlocksDictionary.Id.GRASS
	return BlocksDictionary.Id.AIR
