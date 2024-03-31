extends SubViewport


var _is_being_viewed:bool = false
var _is_being_hovered:bool = false
var _framerate_timer:float = 0.0
var _is_skewing:bool = false
var _skew_time:float = 0.0
var _skew_amount:float = 0.0


const FRAMERATE:float = 0.0625
const SKEW_PROB:float = 0.99
const SKEW_TIME_MIN:float = 0.125
const SKEW_TIME_MAX:float = 0.6
const SKEW_MIN:float = 0.1
const SKEW_MAX:float = 0.25
const SKEW_VARIANCE:float = 0.1
const SKEW_COOLDOWN:float = 4.0


signal return_control


@onready var _screen_obj:MeshInstance3D = $"MeshInstance3D"
@onready var _screen_shader:ShaderMaterial = _screen_obj.get_surface_override_material(0)
@onready var _player_cam:Camera3D = $"../Player/Camera3D"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_framerate_timer += delta
	if _framerate_timer > FRAMERATE:
		_framerate_timer -= FRAMERATE
		render_target_update_mode = SubViewport.UPDATE_ONCE
	
	if !_is_skewing && randf() > SKEW_PROB && _skew_time < -SKEW_COOLDOWN:
		_is_skewing = true
		_skew_time = randf_range(SKEW_TIME_MIN, SKEW_TIME_MAX)
		_skew_amount = randf_range(SKEW_MIN, SKEW_MAX)
	if _is_skewing:
		var frame_skew_amount = _skew_amount + randf_range(-SKEW_VARIANCE, SKEW_VARIANCE)
		_screen_shader.set_shader_parameter("CamOffset", 0.5 - (frame_skew_amount * 2.0))
		_screen_shader.set_shader_parameter("CamSkew", -frame_skew_amount)
		if _skew_time <= 0:
			_is_skewing = false
	else:
		_screen_shader.set_shader_parameter("CamOffset", 0.5)
		_screen_shader.set_shader_parameter("CamSkew", 0.0)
	_skew_time -= delta
	
	if _is_being_viewed:
		if Input.get_action_raw_strength("MoveBackward"):
			_is_being_viewed = false
			return_control.emit()


func _on_player_used_monitor():
	_is_being_viewed = true
	_player_cam.global_position = _screen_obj.global_position + Vector3(0.0, 0.125, -0.5)
	_player_cam.global_rotation_degrees = Vector3(-12.5, 180.0, 0.0)
