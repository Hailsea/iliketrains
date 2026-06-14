extends HBoxContainer

@onready var textbox = $TextBoxMargin
@onready var text = $TextBoxMargin/TextPanel/TextContainer/Text
@onready var portrait = $Portrait

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func update_text(emotion:String,thought_text:String):
	var tween = create_tween()
	textbox.pivot_offset_ratio = Vector2(0,0.5)
	tween.tween_property(textbox,"scale:y",0,0)
	var texture = load("res://Assets/Sprites/Portraits/protag/"+emotion+".png")
	portrait.texture=texture
	text.text = "[i]"+thought_text+"[/i]"
	
	tween.tween_property(textbox,"scale:y",1,0.15)
	
