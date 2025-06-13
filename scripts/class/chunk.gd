class_name Chunk
extends StaticBody3D

################################################################################
# Constants                                                                    #
################################################################################

# This constants is not constants due to the issue:
# https://github.com/godotengine/godot/issues/85557

var VERTICES = [
	Vector3i(0, 0, 0),
	Vector3i(1, 0, 0),
	Vector3i(0, 1, 0),
	Vector3i(1, 1, 0),
	Vector3i(0, 0, 1),
	Vector3i(1, 0, 1),
	Vector3i(0, 1, 1),
	Vector3i(1, 1, 1),
]

# Faces vertices painting order
var TOP_FACE    = [2, 3, 7, 6]
var BOTTOM_FACE = [0, 4, 5, 1]
var LEFT_FACE   = [6, 4, 0, 2]
var RIGHT_FACE  = [3, 1, 5, 7]
var FRONT_FACE  = [7, 5, 4, 6]
var BACK_FACE   = [2, 0, 1, 3]

const DIMENSIONS = Vector3i(16, 128, 16)
# const DIMENSIONS = Vector3i(8, 64, 8)

################################################################################
# Exports                                                                      #
################################################################################

@export var chunk_position: Vector2i
@export var chunk_generator: AbstractChunkGenerator
@export var material: Material

################################################################################
# Members                                                                      #
################################################################################

var collision_shape_3d = CollisionShape3D.new()
var mesh_instance_3d = MeshInstance3D.new()
var surface_tool: SurfaceTool = SurfaceTool.new()
var block_ids # Three-dimensional array of block Ids

################################################################################
# Overridden built-in methods                                                  #
################################################################################

func _init() -> void:
	# Resize block_ids array
	block_ids = []
	block_ids.resize(DIMENSIONS.x)
	for x in DIMENSIONS.x:
		block_ids[x] = []
		block_ids[x].resize(DIMENSIONS.y)
		for y in DIMENSIONS.y:
			block_ids[x][y] = []
			block_ids[x][y].resize(DIMENSIONS.z)

	add_child(collision_shape_3d)
	add_child(mesh_instance_3d)

func _ready() -> void:
	pass

func _exit_tree() -> void:
	mesh_instance_3d.queue_free()
	collision_shape_3d.queue_free()

################################################################################
# Custom methods                                                               #
################################################################################

func fill() -> void:
	for x in range(DIMENSIONS.x):
		for y in range(DIMENSIONS.y):
			for z in range(DIMENSIONS.z):
				block_ids[x][y][z] = chunk_generator.get_block_id(calc_world_pos_by_chunk_pos(Vector3i(x, y, z)))

func draw() -> void:
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for x in range(DIMENSIONS.x):
		for y in range(DIMENSIONS.y):
			for z in range(DIMENSIONS.z):
				if block_ids[x][y][z] != BlockDatabase.Id.AIR:
					draw_block(
						Vector3i(x, y, z),
						Vector3i(chunk_position.x * DIMENSIONS.x + x, y, chunk_position.y * DIMENSIONS.z + z),
						block_ids[x][y][z]
		 			)

	surface_tool.set_material(material)
	var mesh = surface_tool.commit()

	# Apply mesh and generate collision shape
	mesh_instance_3d.mesh = mesh
	collision_shape_3d.shape = mesh.create_trimesh_shape()

func draw_block(block_pos_chunk: Vector3i, block_pos_world: Vector3i, block_id: BlockDatabase.Id) -> void:
	if is_transparent(block_pos_chunk.x, block_pos_chunk.y + 1, block_pos_chunk.z):
		var texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.TOP] + \
			material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
		draw_face(TOP_FACE, block_pos_world, texture_slice)

	if is_transparent(block_pos_chunk.x, block_pos_chunk.y - 1, block_pos_chunk.z):
		var texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.BOTTOM] + \
			material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
		draw_face(BOTTOM_FACE, block_pos_world, texture_slice)

	if is_transparent(block_pos_chunk.x - 1, block_pos_chunk.y, block_pos_chunk.z):
		var texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.LEFT] + \
			material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
		draw_face(LEFT_FACE, block_pos_world, texture_slice)

	if is_transparent(block_pos_chunk.x + 1, block_pos_chunk.y, block_pos_chunk.z):
		var texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.RIGHT] + \
			material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
		draw_face(RIGHT_FACE, block_pos_world, texture_slice)

	if is_transparent(block_pos_chunk.x, block_pos_chunk.y, block_pos_chunk.z + 1):
		var texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.FRONT] + \
			material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
		draw_face(FRONT_FACE, block_pos_world, texture_slice)

	if is_transparent(block_pos_chunk.x, block_pos_chunk.y, block_pos_chunk.z - 1):
		var texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.BACK] + \
			material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
		draw_face(BACK_FACE, block_pos_world, texture_slice)

func is_transparent(x, y, z) -> bool:
	if  x >= 0 and x < DIMENSIONS.x and \
		y >= 0 and y < DIMENSIONS.y and \
		z >= 0 and z < DIMENSIONS.z:
		return block_ids[x][y][z] == BlockDatabase.Id.AIR # And some glass blocks in the future
	return true

func draw_face(face: Array, block_pos_world: Vector3i, texture_slice: float) -> void:
	# A -- D
	# | \  | Drawing order
	# |  \ |
	# B -- C

	var a: Vector3 = VERTICES[face[0]] + block_pos_world
	var b: Vector3 = VERTICES[face[1]] + block_pos_world
	var c: Vector3 = VERTICES[face[2]] + block_pos_world
	var d: Vector3 = VERTICES[face[3]] + block_pos_world

	# U, V and slice offset
	var uv_a = Vector2(0.0, 0.0)
	var uv_b = Vector2(0.0, 1.0)
	var uv_c = Vector2(1.0, 1.0)
	var uv_d = Vector2(1.0, 0.0)

	# Calculate normals
	var side_a = b - a
	var side_b = a - c
	var normal = side_a.cross(side_b)

	surface_tool.add_triangle_fan([a, b, c], [uv_a, uv_b, uv_c], [], [Vector2(texture_slice, 0.0)], [normal])
	surface_tool.add_triangle_fan([a, c, d], [uv_a, uv_c, uv_d], [], [Vector2(texture_slice, 0.0)], [normal])

func is_solid(block_position: Vector3i) -> bool:
	return block_ids[block_position.x][block_position.y][block_position.z] != BlockDatabase.Id.AIR

func calc_world_pos_by_chunk_pos(input: Vector3i) -> Vector3i:
	return Vector3i(chunk_position.x * DIMENSIONS.x + input.x, input.y, chunk_position.y * DIMENSIONS.z + input.z)
