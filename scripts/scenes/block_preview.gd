@tool

extends Node3D

################################################################################
# Exports                                                                      #
################################################################################

@export var block_id: BlockDatabase.Id:
	set(new_block_id):
		block_id = new_block_id
		if is_node_ready():
			draw()

@export var material: Material:
	set(new_material):
		material = new_material
		if is_node_ready():
			draw()

################################################################################
# On-ready variables                                                           #
################################################################################

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

################################################################################
# Overridden built-in methods                                                  #
################################################################################

func _ready() -> void:
	draw()

################################################################################
# Custom methods                                                               #
################################################################################

func draw() -> void:
	if block_id == BlockDatabase.Id.AIR:
		mesh_instance_3d.mesh = null
		return

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_material(material)

	# Top face
	var texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.TOP] + \
		material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
	_draw_face(surface_tool, Block.TOP_FACE, texture_slice)

	# Bottom face
	texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.BOTTOM] + \
		material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
	_draw_face(surface_tool, Block.BOTTOM_FACE, texture_slice)

	# Left face
	texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.LEFT] + \
		material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
	_draw_face(surface_tool, Block.LEFT_FACE, texture_slice)

	# Right face
	texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.RIGHT] + \
		material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
	_draw_face(surface_tool, Block.RIGHT_FACE, texture_slice)

	# Front face
	texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.FRONT] + \
		material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
	_draw_face(surface_tool, Block.FRONT_FACE, texture_slice)

	# Back face
	texture_slice = BlockDatabase.get_texture_indices(block_id)[BlockDatabase.Side.BACK] + \
		material.get_shader_parameter("texture_array").get_texture_slice_offset(block_id)
	_draw_face(surface_tool, Block.BACK_FACE, texture_slice)

	mesh_instance_3d.mesh = surface_tool.commit()

func _draw_face(st: SurfaceTool, face: Array, texture_slice: float) -> void:
	# A -- D
	# | \  | Drawing order
	# |  \ |
	# B -- C

	var a: Vector3 = Block.VERTICES[face[0]]
	var b: Vector3 = Block.VERTICES[face[1]]
	var c: Vector3 = Block.VERTICES[face[2]]
	var d: Vector3 = Block.VERTICES[face[3]]

	var uv_a = Vector2(0.0, 0.0)
	var uv_b = Vector2(0.0, 1.0)
	var uv_c = Vector2(1.0, 1.0)
	var uv_d = Vector2(1.0, 0.0)

	var side_a = b - a
	var side_b = a - c
	var normal = side_a.cross(side_b)

	st.add_triangle_fan([a, b, c], [uv_a, uv_b, uv_c], [], [Vector2(texture_slice, 0.0)], [normal])
	st.add_triangle_fan([a, c, d], [uv_a, uv_c, uv_d], [], [Vector2(texture_slice, 0.0)], [normal])
