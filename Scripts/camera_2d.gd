extends Camera2D

var MAX_OFFSET_X: float
var MAX_OFFSET_Y: float

var camera_offset: Vector2

var lock:bool = false

func _ready() -> void:
	camera_offset = get_viewport().size*0.5


func _physics_process(delta):
	if not lock:
		var mouse_pos = get_viewport().get_mouse_position()
		position = (mouse_pos-camera_offset)*0.15 + camera_offset
