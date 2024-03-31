extends CharacterBody3D


const SPEED:float = 5.0
const JUMP_VELOCITY:float = 4.5
const ACCEL:float = 40.0
const ABS_VERT_CAM_ROT:float = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _vel:float = 0.0
var _direction:Vector3
var _controllable:bool = true
var _last_cam_pitch:float = 0.0


signal used_monitor
signal used_left_door
signal used_right_door


@onready var cam:Camera3D = $"Camera3D"
@onready var interact_cast:RayCast3D = $"Camera3D/InteractCast"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Are we even accepting control right now?
	if !_controllable:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var new_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if new_dir:
		_direction = new_dir
		_vel = move_toward(_vel, SPEED, ACCEL * delta)
	else:
		_vel = move_toward(_vel, 0, ACCEL * delta)
	velocity.x = _direction.x * _vel
	velocity.z = _direction.z * _vel

	move_and_slide()
	
	if Input.get_action_raw_strength("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_action_raw_strength("Interact"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var obj:CollisionObject3D = interact_cast.get_collider()
	if obj:
		if Input.get_action_raw_strength("Interact"):
			match obj.name:
				"MonitorInteractable":
					used_monitor.emit()
					_controllable = false
					visible = false
				_:
					return

func _input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && _controllable:
		var cam_rot = event.relative * ProjectSettings.get_setting("global/mouse_sensitivity") * -0.25
		rotation.y += cam_rot.x
		cam.rotation.x = clamp(cam.rotation.x + cam_rot.y, -ABS_VERT_CAM_ROT, ABS_VERT_CAM_ROT)
		_last_cam_pitch = cam.rotation.x


func on_control_returned():
	_controllable = true
	cam.position = Vector3(0.0, 0.5, 0.0)
	cam.rotation.y = 0.0
	cam.rotation.x = _last_cam_pitch
	visible = true
