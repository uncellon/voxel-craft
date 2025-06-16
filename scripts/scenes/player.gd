class_name Player
extends CharacterBody3D

################################################################################
# Signals                                                                      #
################################################################################

signal hotbar_selected_index_changed

################################################################################
# Constants                                                                    #
################################################################################

const SPEED = 5.0
const JUMP_VELOCITY = 6.5
const HOTBAR_CAPACITY = 9

################################################################################
# Members                                                                      #
################################################################################

var look_sensetivity = 0.002
var hotbar_selected_item_index = 0

################################################################################
# On-ready variables                                                           #
################################################################################

@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var chunk_manager: Node3D = $"../ChunkManager"

################################################################################
# Overridden built-in methods                                                  #
################################################################################

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_set_hotbar_selected_item_index(0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y = rotation.y - event.relative.x * look_sensetivity
		camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * look_sensetivity
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90.0), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Handle mouse clicks
	if Input.is_action_just_pressed("left_click"):
		if ray_cast_3d.is_colliding():
			chunk_manager.destroy_block(
				ray_cast_3d.get_collision_point() - (ray_cast_3d.get_collision_normal() / 2)
			)
	if Input.is_action_just_pressed("right_click"):
		if ray_cast_3d.is_colliding():
			chunk_manager.place_block(
				ray_cast_3d.get_collision_point() + (ray_cast_3d.get_collision_normal() / 2), BlockDatabase.Id.PLANKS
			)

	if Input.is_action_just_pressed("wheel_up"):
		_set_hotbar_selected_item_index(hotbar_selected_item_index + 1)

	if Input.is_action_just_pressed("wheel_down"):
		_set_hotbar_selected_item_index(hotbar_selected_item_index - 1)

	if Input.is_action_just_pressed("key_1"):
		_set_hotbar_selected_item_index(0)

	if Input.is_action_just_pressed("key_2"):
		_set_hotbar_selected_item_index(1)

	if Input.is_action_just_pressed("key_3"):
		_set_hotbar_selected_item_index(2)

	if Input.is_action_just_pressed("key_4"):
		_set_hotbar_selected_item_index(3)

	if Input.is_action_just_pressed("key_5"):
		_set_hotbar_selected_item_index(4)

	if Input.is_action_just_pressed("key_6"):
		_set_hotbar_selected_item_index(5)

	if Input.is_action_just_pressed("key_7"):
		_set_hotbar_selected_item_index(6)

	if Input.is_action_just_pressed("key_8"):
		_set_hotbar_selected_item_index(7)

	if Input.is_action_just_pressed("key_9"):
		_set_hotbar_selected_item_index(8)

	move_and_slide()

################################################################################
# Methods                                                                      #
################################################################################

func _set_hotbar_selected_item_index(value: int):
	if value >= HOTBAR_CAPACITY:
		value = 0
	elif value < 0:
		value = HOTBAR_CAPACITY - 1

	hotbar_selected_item_index = value
	hotbar_selected_index_changed.emit(hotbar_selected_item_index)
