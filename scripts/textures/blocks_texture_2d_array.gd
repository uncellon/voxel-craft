class_name BlocksTexture2DArray
extends Texture2DArray

################################################################################
# Members                                                                      #
################################################################################

var slice_offsets_by_ids: Dictionary
var last_free_index: int = 0

################################################################################
# Overridden built-in methods                                                  #
################################################################################

func _init() -> void:
	var loaded_textures = []

	for block_id in BlockDatabase.BLOCKS:
		slice_offsets_by_ids[block_id] = last_free_index
		for texture_path in BlockDatabase.get_texture_paths(block_id):
			last_free_index = last_free_index + 1

			var res = ResourceLoader.load(texture_path)
			var image = res.get_image()

			image.decompress()
			image.convert(Image.FORMAT_RGBA8)
			image.srgb_to_linear()
			image.generate_mipmaps()

			loaded_textures.append(image)

	create_from_images(loaded_textures)


################################################################################
# Custom methods                                                               #
################################################################################

func get_texture_slice_offset(id: BlockDatabase.Id) -> int:
	return slice_offsets_by_ids[id]
