class_name BlockDatabase
extends RefCounted

################################################################################
# Enums                                                                        #
################################################################################

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

################################################################################
# Constants                                                                    #
################################################################################

const BLOCKS = {
	Id.GRASS: {
		"textures": [
			"res://assets/textures/blocks/grass_top.png",
			"res://assets/textures/blocks/grass_side.png",
			"res://assets/textures/blocks/dirt.png"
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
		"textures": [ "res://assets/textures/blocks/planks.png" ]
	}
}

################################################################################
# Static methods                                                               #
################################################################################

static func get_texture_indices(id: BlockDatabase.Id) -> Dictionary:
	return BLOCKS[id]["texture_indices"]

static func get_texture_paths(id: BlockDatabase.Id) -> Array:
	return BLOCKS[id]["textures"]