class_name BlockResource extends Resource

enum TextureDirection {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	FRONT,
	BACK
}

@export var id: int
@export var name: String
@export var texcoords: Dictionary = {
	"top_face": {
		"top_left": Vector2(0, 0),
		"top_right": Vector2(0, 1.0),
		"bottom_left": Vector2(1.0, 0),
		"bottom_right": Vector2(1.0, 1.0)
	},
	"bottom_face": {
		"top_left": Vector2(0, 0),
		"top_right": Vector2(0, 1.0),
		"bottom_left": Vector2(1.0, 0),
		"bottom_right": Vector2(1.0, 1.0)
	},
	"left_face": {
		"top_left": Vector2(0, 0),
		"top_right": Vector2(0, 1.0),
		"bottom_left": Vector2(1.0, 0),
		"bottom_right": Vector2(1.0, 1.0)
	},
	"right_face": {
		"top_left": Vector2(0, 0),
		"top_right": Vector2(0, 1.0),
		"bottom_left": Vector2(1.0, 0),
		"bottom_right": Vector2(1.0, 1.0)
	},
	"front_face": {
		"top_left": Vector2(0, 0),
		"top_right": Vector2(0, 1.0),
		"bottom_left": Vector2(1.0, 0),
		"bottom_right": Vector2(1.0, 1.0)
	},
	"back_face": {
		"top_left": Vector2(0, 0),
		"top_right": Vector2(0, 1.0),
		"bottom_left": Vector2(1.0, 0),
		"bottom_right": Vector2(1.0, 1.0)
	}
}
@export var material: Material
# TO-DO
#@export var is_collidable: bool = true
#@export var is_transparent: bool = false
