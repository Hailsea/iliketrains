extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.wait_time = 3
	await $Timer.timeout
	$PanelContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/Messages/messagedisplay1.show()
	$PanelContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/Messages/separatordisplay.show()
	
	await $Timer.timeout
	$PanelContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/Messages/messagedisplay2.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
