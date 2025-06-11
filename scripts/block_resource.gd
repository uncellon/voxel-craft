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
#@export var textures: Dictionary = {
	#"top": Vector2(0, 0),
	#"bottom": Vector2(0, 0),
	#"left": Vector2(0, 0),
	#"right": Vector2(0, 0),
	#"front": Vector2(0, 0),
	#"back": Vector2(0, 0)
#}
@export var material: Material
# TO-DO
#@export var is_collidable: bool = true
#@export var is_transparent: bool = false
