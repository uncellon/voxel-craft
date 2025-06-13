class_name BlocksDictionary extends RefCounted

enum Id {
	AIR,
	GRASS,
	PLANKS
}

enum Side {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	FRONT,
	BACK
}

const BLOCKS = {
	Id.GRASS: {
		"textures": [
			"res://assets/textures/grass_top.png",
			"res://assets/textures/grass_side.png",
			"res://assets/textures/dirt.png"
		],
		"texture_indices": {
			Side.TOP: 0,
			Side.BOTTOM: 2,
			Side.LEFT: 1,
			Side.RIGHT: 1,
			Side.FRONT: 1,
			Side.BACK: 1,
		}
	},
	Id.PLANKS: {
		"textures": [ "res://assets/textures/planks.png" ]
	}
}

static func get_texture_indices(id: BlocksDictionary.Id) -> Dictionary:
	return BLOCKS[id]["texture_indices"]
