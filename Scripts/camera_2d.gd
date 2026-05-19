extends Camera2D

var MAX_OFFSET_X: float
var MAX_OFFSET_Y: float

var camera_offset: Vector2

func _ready() -> void:
	camera_offset = get_viewport().size*0.1


func _physics_process(delta):
	position = get_viewport().get_mouse_position()*0.2 - 0*camera_offset
