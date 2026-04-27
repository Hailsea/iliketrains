extends Control

@onready var portrait = $GlobalContainer/Portrait
@onready var character_name = $GlobalContainer/TextBoxContainer/NameBoxMargin/MarginPanel/NameMargin/Name
@onready var text = $GlobalContainer/TextBoxContainer/TextBoxMargin/TextPanel/TextMargin/Text
@onready var textbox_panel = $GlobalContainer/TextBoxContainer/TextBoxMargin/TextPanel

@onready var timer = $TypewriterTimer

const DEFAULT_SPEED = 40
var anim_speed = DEFAULT_SPEED
var animate_text = false
var displayed_text = ""
var visible_characters_ratio = 0

var unskip : bool = false
var previous_character: String = ""

var index:int = 0
var lines:Array[Dictionary] = [
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Voila où j'en suis pour l'interface de dialogue, c'est pas encore très avancé mais c'est un début.","properties":["unskip"]},
	{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Ça supporte la [color=red]couleur[/color] et le rich text de Godot donc c'est sympa !","properties":[]},
	{"character":"futaba","emotion":"neutral","character_name":"Futaba","text":"Coucou ! On peut avoir plusieurs personnages !","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Et vous savez quoi ?","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"J'ai perdu !","properties":[],"speed":5},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"...","properties":[],"speed":10},
]

var tween : Tween



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_line(lines[index])
	
	
func _process(delta):
	if animate_text:
		if text.visible_ratio < 1:
			text.visible_ratio += (1.0/text.text.length()) * (anim_speed * delta)
		else:
			animate_text = false

func skip_animation():
	text.visible_ratio = 1
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dialog_next"):
		if animate_text == true:
			if !unskip:
				skip_animation()
		elif index < len(lines) - 1:
				index += 1
				display_line(lines[index])

func display_line(line: Dictionary):
	var path = "res://Assets/Sprites/Portraits/" + line["character"] + "/" + line["emotion"] + ".png"
	var img = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(img)
	
	portrait.texture = texture
	character_name.text = line["character_name"]
	text.text = line["text"]
	
	if "unskip" in line["properties"]:
		unskip = true
	else:
		unskip = false
	
	if line.has("speed"):
		anim_speed = line["speed"]
	else:
		anim_speed = DEFAULT_SPEED
	
	text.visible_characters = 0
	animate_text = true
	
	
	
	if line["character_name"] != previous_character:
		previous_character = line["character_name"]
		textbox_animation()

func textbox_animation() -> void:
	textbox_panel.pivot_offset_ratio = Vector2(0,0.5)
	
	tween = create_tween()
	tween.tween_property(textbox_panel, "scale:y", 0, 0)
	tween.tween_property(textbox_panel, "scale:y", 1, 0.2)

#func clear_text():
	#if text.text.length() > 0:
		#text.text = ""
	#
#func typewriter(line_text:String) -> void:
	#clear_text()
	#timer.wait_time = delay
	#timer.one_shot = true
	#
	#for char in line_text.length():
		#text.text += line_text[char]
		#
		#timer.stop()
		#timer.start()
		#await timer.timeout
		
		
