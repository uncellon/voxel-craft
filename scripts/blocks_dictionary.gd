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
		"material_path": "res://assets/materials/debug.tres",
		"uvs": {
			Side.TOP: [0.0, 0.0, 1.0, 1.0],
			Side.BOTTOM: [0.0, 0.0, 1.0, 1.0],
			Side.LEFT: [0.0, 0.0, 1.0, 1.0],
			Side.RIGHT: [0.0, 0.0, 1.0, 1.0],
			Side.FRONT: [0.0, 0.0, 1.0, 1.0],
			Side.BACK: [0.0, 0.0, 1.0, 1.0],
		}
	},
	Id.PLANKS: {
		"material_path": "res://assets/materials/planks.tres",
		"uvs": {
			Side.TOP: [0.0, 0.0, 1.0, 1.0],
			Side.BOTTOM: [0.0, 0.0, 1.0, 1.0],
			Side.LEFT: [0.0, 0.0, 1.0, 1.0],
			Side.RIGHT: [0.0, 0.0, 1.0, 1.0],
			Side.FRONT: [0.0, 0.0, 1.0, 1.0],
			Side.BACK: [0.0, 0.0, 1.0, 1.0],
		}
	}
}

static func get_uvs(id: BlocksDictionary.Id, side: BlocksDictionary.Side) -> Array:
	return BLOCKS[id]["uvs"][side]

static func get_material_path(id: BlocksDictionary.Id) -> String:
	return BLOCKS[id]["material_path"]