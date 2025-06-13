class_name BlocksTextureArray
extends Texture2DArray

################################################################################
# Members                                                                      #
################################################################################

var indices_by_ids: Dictionary # BlockDictionary.Id : Offset
var loaded_textures: Array = []
var current_free_index: int = 0

################################################################################
# Overridden built-in methods                                                  #
################################################################################

func _init() -> void:
	for block_id in BlocksDictionary.BLOCKS:
		var indices = []
		indices_by_ids[block_id] = current_free_index
		for texture_path in BlocksDictionary.BLOCKS[block_id]["textures"]:
			var res = ResourceLoader.load(texture_path)
			var image = res.get_image()

			image.decompress()
			image.convert(Image.FORMAT_RGBA8)
			image.srgb_to_linear()
			image.generate_mipmaps()

			loaded_textures.append(image)

			indices.append(current_free_index)
			print(str("Loaded texture: \"", texture_path, "\" with index: ", current_free_index))
			current_free_index = current_free_index + 1

	create_from_images(loaded_textures)


################################################################################
# Custom methods                                                               #
################################################################################

func get_textures_indices(id: BlocksDictionary.Id) -> int:
	return indices_by_ids[id]
