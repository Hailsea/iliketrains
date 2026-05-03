extends Node

@onready var dialog:Control = $DialogUI;
@onready var think:Control = $ThinkUI;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("dialog_think"):
		dialog.modulate = Color(0.5, 0.5, 0.5, 1.0)
		think.show()
	else:
		dialog.modulate = Color(1, 1, 1, 1.0)
		think.hide()
