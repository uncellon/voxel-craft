extends CharacterBody3D

################################################################################
# Constants                                                                    #
################################################################################

const SPEED = 5.0 * 5
const JUMP_VELOCITY = 6.5

################################################################################
# Members                                                                      #
################################################################################

var look_sensetivity = 0.002

################################################################################
# On-ready variables                                                           #
################################################################################

@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D

################################################################################
# Overridden built-in methods                                                  #
################################################################################

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("destroy_block"):
			ray_cast_3d.get_collider().destroy(
				ray_cast_3d.get_collision_point() - (ray_cast_3d.get_collision_normal() / 2)
			)
	if Input.is_action_just_pressed("right_click"):
		if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("place_block"):
			ray_cast_3d.get_collider().place(
				ray_cast_3d.get_collision_point() + (ray_cast_3d.get_collision_normal() / 2), 1
			)

	move_and_slide()
