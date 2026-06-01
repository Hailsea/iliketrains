extends HBoxContainer

@onready var textbox = $TextBoxMargin
@onready var text = $TextBoxMargin/TextPanel/TextContainer/Text
@onready var portrait = $Portrait

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_text(emotion:String,thought_text:String):
	var tween = create_tween()
	textbox.pivot_offset_ratio = Vector2(0,0.5)
	tween.tween_property(textbox,"scale:y",0,0)
	var img = Image.load_from_file("res://Assets/Sprites/Portraits/protag/"+emotion+".png")
	var texture = ImageTexture.create_from_image(img)
	portrait.texture=texture
	text.text = thought_text
	
	tween.tween_property(textbox,"scale:y",1,0.15)
	
