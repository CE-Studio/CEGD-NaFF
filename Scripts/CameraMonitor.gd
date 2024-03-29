extends SubViewport


var _is_being_viewed:bool = false
var _is_being_hovered:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_being_hovered && !_is_being_viewed && Input.get_action_raw_strength("Interact"):
		_is_being_viewed = true
	if _is_being_viewed && Input.get_action_raw_strength("MoveBackward"):
		_is_being_viewed = false
	print(_is_being_viewed)


func _on_mouse_entered():
	_is_being_hovered = true


func _on_mouse_exited():
	_is_being_hovered = false
