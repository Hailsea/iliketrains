extends Control

@onready var portrait = $GlobalContainer/Portrait
@onready var character_name = $GlobalContainer/TextBoxContainer/NameBoxMargin/MarginPanel/NameMargin/Name
@onready var text = $GlobalContainer/TextBoxContainer/TextBoxMargin/TextPanel/TextMargin/Text

var index:int = 0
var lines:Array[Dictionary] = [
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Ceci est un test."},
	{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"J'aime les pâtes au chocolat."},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_line(lines[index])
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dialog_next"):
		if index < len(lines) - 1:
			index += 1
			display_line(lines[index])

func display_line(line: Dictionary):
	var path = "res://Assets/Sprites/Portraits/" + line["character"] + "/" + line["emotion"] + ".png"
	var img = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(img)

	portrait.texture = texture
	character_name.text = line["character_name"]
	text.text = line["text"]
	
