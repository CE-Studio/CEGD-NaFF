extends CharacterBody3D


const SPEED:float = 5.0
const JUMP_VELOCITY:float = 4.5
const ACCEL:float = 40.0
const ABS_VERT_CAM_ROT:float = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var vel:float = 0.0
var direction:Vector3


@onready var cam:Camera3D = $"Camera3D"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
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
	if Input.get_action_raw_strength("Interact"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var cam_rot = event.relative * ProjectSettings.get_setting("global/mouse_sensitivity") * -0.25
		rotation.y += cam_rot.x
		cam.rotation.x = clamp(cam.rotation.x + cam_rot.y, -ABS_VERT_CAM_ROT, ABS_VERT_CAM_ROT)
