class_name FlatChunkGenerator extends Resource

func calc_block(block_position: Vector3i) -> Block:
	if block_position.y < 1:
		return Block.new()
	return null
