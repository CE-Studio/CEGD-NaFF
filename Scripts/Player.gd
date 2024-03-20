extends CharacterBody3D


const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const ACCEL := 25.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vel := 0.0
var direction:Vector3


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Handle mouse movement.
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var look_vel = Input.get_last_mouse_velocity()
		rotation.y += look_vel.x * delta * ProjectSettings.get_setting("global/mouse_sensitivity") * -0.25
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var new_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if new_dir:
		direction = new_dir
		vel = move_toward(vel, SPEED, ACCEL * delta)
	else:
		vel = move_toward(vel, 0, ACCEL * delta)
	velocity.x = direction.x * vel
	velocity.z = direction.z * vel

	move_and_slide()
	
	if Input.get_action_raw_strength("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
