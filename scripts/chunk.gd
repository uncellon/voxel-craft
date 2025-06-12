class_name Chunk extends StaticBody3D

const VERTICES = [
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
const TOP_FACE    = [2, 3, 7, 6]
const BOTTOM_FACE = [0, 4, 5, 1]
const LEFT_FACE   = [6, 4, 0, 2]
const RIGHT_FACE  = [3, 1, 5, 7]
const FRONT_FACE  = [7, 5, 4, 6]
const BACK_FACE   = [2, 0, 1, 3]

# const DIMENSIONS = Vector3i(32, 128, 32)
const DIMENSIONS = Vector3i(8, 64, 8)

@export var chunk_position: Vector2i
@export var chunk_generator: ChunkGenerator

var collision_shape_3d = CollisionShape3D.new()
var mesh_instance_3d = MeshInstance3D.new()
var surface_tool: SurfaceTool = SurfaceTool.new()
var block_ids # Three-dimensional array of block Ids

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


func _ready() -> void:
	add_child(collision_shape_3d)
	add_child(mesh_instance_3d)

func fill_and_draw_RENAME_THIS() -> void:
	fill()
	draw()

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
				if block_ids[x][y][z] != BlocksDictionary.Id.AIR:
					draw_block(
						Vector3i(x, y, z),
						Vector3i(chunk_position.x * DIMENSIONS.x + x, y, chunk_position.y * DIMENSIONS.z + z),
						block_ids[x][y][z]
		 			)

					# Load material
					var material_path = BlocksDictionary.get_material_path(block_ids[x][y][z])
					if ResourceLoader.exists(material_path):
						surface_tool.set_material(ResourceLoader.load(material_path))

	var mesh = surface_tool.commit()

	# Apply mesh and generate collision shape
	mesh_instance_3d.mesh = mesh
	collision_shape_3d.shape = mesh.create_trimesh_shape()

func draw_block(block_pos_chunk: Vector3i, block_pos_world: Vector3i, block_id: BlocksDictionary.Id) -> void:
	if is_transparent(block_pos_chunk.x, block_pos_chunk.y + 1, block_pos_chunk.z):
		draw_face(TOP_FACE, block_pos_world, BlocksDictionary.get_uvs(block_id, BlocksDictionary.Side.TOP))

	if is_transparent(block_pos_chunk.x, block_pos_chunk.y - 1, block_pos_chunk.z):
		draw_face(BOTTOM_FACE, block_pos_world, BlocksDictionary.get_uvs(block_id, BlocksDictionary.Side.BOTTOM))

	if is_transparent(block_pos_chunk.x - 1, block_pos_chunk.y, block_pos_chunk.z):
		draw_face(LEFT_FACE, block_pos_world, BlocksDictionary.get_uvs(block_id, BlocksDictionary.Side.LEFT))

	if is_transparent(block_pos_chunk.x + 1, block_pos_chunk.y, block_pos_chunk.z):
		draw_face(RIGHT_FACE, block_pos_world, BlocksDictionary.get_uvs(block_id, BlocksDictionary.Side.RIGHT))

	if is_transparent(block_pos_chunk.x, block_pos_chunk.y, block_pos_chunk.z + 1):
		draw_face(FRONT_FACE, block_pos_world, BlocksDictionary.get_uvs(block_id, BlocksDictionary.Side.FRONT))

	if is_transparent(block_pos_chunk.x, block_pos_chunk.y, block_pos_chunk.z - 1):
		draw_face(BACK_FACE, block_pos_world, BlocksDictionary.get_uvs(block_id, BlocksDictionary.Side.BACK))

func is_transparent(x, y, z) -> bool:
	if  x >= 0 and x < DIMENSIONS.x and \
		y >= 0 and y < DIMENSIONS.y and \
		z >= 0 and z < DIMENSIONS.z:
		return block_ids[x][y][z] == BlocksDictionary.Id.AIR # And some glass blocks in the future
	return true

func draw_face(face: Array, block_pos_world: Vector3i, texcoords: Array) -> void:
	# A -- D
	# | \  | Drawing order
	# |  \ |
	# B -- C

	var a: Vector3 = VERTICES[face[0]] + block_pos_world
	var b: Vector3 = VERTICES[face[1]] + block_pos_world
	var c: Vector3 = VERTICES[face[2]] + block_pos_world
	var d: Vector3 = VERTICES[face[3]] + block_pos_world

	var uv_a = Vector2(texcoords[0], texcoords[0])
	var uv_b = Vector2(texcoords[0], texcoords[1])
	var uv_c = Vector2(texcoords[1], texcoords[1])
	var uv_d = Vector2(texcoords[1], texcoords[0])

	# Calculate normals
	var side_a = b - a
	var side_b = a - c
	var normal = side_a.cross(side_b)

	surface_tool.add_triangle_fan([a, b, c], [uv_a, uv_b, uv_c], [], [], [normal])
	surface_tool.add_triangle_fan([a, c, d], [uv_a, uv_c, uv_d], [], [], [normal])

func is_solid(block_position: Vector3i) -> bool:
	return block_ids[block_position.x][block_position.y][block_position.z] != BlocksDictionary.Id.AIR

func calc_world_pos_by_chunk_pos(input: Vector3i) -> Vector3i:
	return Vector3i(chunk_position.x * DIMENSIONS.x + input.x, input.y, chunk_position.y * DIMENSIONS.z + input.z)
