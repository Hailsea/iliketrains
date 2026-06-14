extends Node2D

const anim_speed = 20
var text = null
var old_character_visible = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if text != null and text.visible_ratio < 1:
		
		text.visible_ratio += (1.0/text.text.length()) * (anim_speed * delta)
		if old_character_visible != text.visible_characters:
			old_character_visible = text.visible_characters
		
		if text.visible_ratio == 1:
			text_anim_finished.emit()
			
signal text_anim_finished

func show_end_text():
	$FinalText/ColorRect.show()
	var tween = create_tween()
	tween.tween_property($FinalText/ColorRect,"modulate:a",0,0)
	tween.tween_property($FinalText/ColorRect,"modulate:a",1,2)
	await tween.finished
	
	$Timer.wait_time = 1
	$Timer.start()
	await $Timer.timeout
	
	text = $FinalText/ColorRect/RichTextLabel
	
	await neverend_signal
	
	
signal neverend_signal
