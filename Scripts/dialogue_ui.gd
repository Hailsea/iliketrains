extends Control

# Récupération des nodes
@onready var portrait:TextureRect = $Portrait
@onready var player_portrait:TextureRect = $PlayerPortrait
@onready var character_name:RichTextLabel = $TextBoxContainer/NameBoxMargin/CharacterPanel/NameMargin/Name
@onready var character_name_panel:PanelContainer = $TextBoxContainer/NameBoxMargin/CharacterPanel
@onready var text:RichTextLabel = $TextBoxContainer/TextBoxMargin/TextPanel/TextMargin/Text
@onready var textbox_panel:PanelContainer = $TextBoxContainer/TextBoxMargin/TextPanel


const portrait_path:String = "res://Assets/Sprites/Portraits/"
const player_character:String = "mishima"

# Variables pour l'effect Machine à [color=redÉcrire
const DEFAULT_SPEED = 40
var anim_speed = DEFAULT_SPEED
var animate_text = false
var displayed_text = ""
var visible_characters_ratio = 0


var unskip : bool = false # true si la ligne en cours est unskippable
var previous_character: String = "" # Pour lancer l'animation de changement de perso

# ==== Potentiellement à supprimer ====
var index:int = 0 # Index de la ligne en cours 
var lines = [
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Voila où j'en suis pour l'interface de dialogue, c'est pas encore très avancé mais c'est un début.","properties":["unskip"]},
	{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Ça supporte la [color=red]couleur[/color] et le rich text de Godot donc c'est sympa !","properties":[]},
	{"character":"futaba","emotion":"neutral","character_name":"Futaba","text":"Coucou ! On peut avoir plusieurs personnages !","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Et vous savez quoi ?","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"J'ai perdu !","properties":[],"speed":1},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"...","properties":[],"speed":10},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Voila où j'en suis pour l'interface de dialogue, c'est pas encore très avancé mais c'est un début.","properties":["unskip"]},
	{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Ça supporte la [color=red]couleur[/color] et le rich text de Godot donc c'est sympa !","properties":[]},
	{"character":"futaba","emotion":"neutral","character_name":"Futaba","text":"Coucou ! On peut avoir plusieurs personnages !","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Et vous savez quoi ?","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"J'ai perdu !","properties":[],"speed":1},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"...","properties":[],"speed":10},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Voila où j'en suis pour l'interface de dialogue, c'est pas encore très avancé mais c'est un début.","properties":["unskip"]},
	{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Ça supporte la [color=red]couleur[/color] et le rich text de Godot donc c'est sympa !","properties":[]},
	{"character":"futaba","emotion":"neutral","character_name":"Futaba","text":"Coucou ! On peut avoir plusieurs personnages !","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Et vous savez quoi ?","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"J'ai perdu !","properties":[],"speed":1},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"...","properties":[],"speed":10},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Voila où j'en suis pour l'interface de dialogue, c'est pas encore très avancé mais c'est un début.","properties":["unskip"]},
	{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Ça supporte la [color=red]couleur[/color] et le rich text de Godot donc c'est sympa !","properties":[]},
	{"character":"futaba","emotion":"neutral","character_name":"Futaba","text":"Coucou ! On peut avoir plusieurs personnages !","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Et vous savez quoi ?","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"J'ai perdu !","properties":[],"speed":1},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"...","properties":[],"speed":10},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Voila où j'en suis pour l'interface de dialogue, c'est pas encore très avancé mais c'est un début.","properties":["unskip"]},
	{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Ça supporte la [color=red]couleur[/color] et le rich text de Godot donc c'est sympa !","properties":[]},
	{"character":"futaba","emotion":"neutral","character_name":"Futaba","text":"Coucou ! On peut avoir plusieurs personnages !","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Et vous savez quoi ?","properties":[]},
	{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"J'ai perdu !","properties":[],"speed":1},
	{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"...","properties":[],"speed":10},
] 
# ====

var tween : Tween # Tween pour les animations

func _ready() -> void:
	pass
	
	
func _process(delta):
	if animate_text:
		if text.visible_ratio < 1:
			text.visible_ratio += (1.0/text.text.length()) * (anim_speed * delta)
		else:
			animate_text = false
			
func get_portrait_path(character, emotion) -> String:
	return portrait_path + character + "/" + emotion + ".png"

func start_typewriter():
	text.visible_characters = 0
	animate_text = true

func skip_typewriter():
	text.visible_ratio = 1
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dialog_next"):
		if animate_text == true:
			if !unskip:
				skip_typewriter()
		elif index < len(lines) - 1:
				index += 1
				display_line(lines[index])
		elif index == len(lines) - 1:
			end_dialog.emit()

func load_lines(dialog_lines):
	lines = dialog_lines
	index = 0
	display_line(lines[index])

func display_line(line: Dictionary):
	var path = get_portrait_path(line["character"],line["emotion"])
	var img = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(img) # Chargement de la texture du portrait pour le TextureRect
	
	
	character_name.text = line["character_name"] # Changement nom du perso
	text.text = line["text"] # Changement contenu du texte
	
	if "unskip" in line["properties"]:
		unskip = true
	else:
		unskip = false
	
	if line.has("speed"): # Vitesse animation
		anim_speed = line["speed"]
	else:
		anim_speed = DEFAULT_SPEED
		
	start_typewriter()
	
	if line["character"] != previous_character:
		previous_character = line["character"]
		if previous_character == player_character:
			switch_to_right(texture)
		else:
			switch_to_left(texture)
		textbox_animation()

func switch_to_left(texture:Texture2D):
	print("switch left")
	portrait.show()
	portrait.texture = texture # Changement portrait
	# player_portrait.texture=null
	player_portrait.hide()
	character_name_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	character_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func switch_to_right(texture:Texture2D):
	print("switch right")
	player_portrait.show()
	player_portrait.texture = texture # Changement portrait
	# portrait.texture=null
	portrait.hide()
	character_name_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	character_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	
	

func textbox_animation() -> void:
	textbox_panel.pivot_offset_ratio = Vector2(0,0.5)
	
	tween = create_tween()
	tween.tween_property(textbox_panel, "scale:y", 0, 0)
	tween.tween_property(textbox_panel, "scale:y", 1, 0.2)

		
signal end_dialog()
