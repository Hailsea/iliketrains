extends Control

# Récupération des nodes
@onready var portrait:TextureRect = $Portrait
@onready var portrait_shadow:TextureRect = $Portrait/Shadow
@onready var player_portrait:TextureRect = $PlayerPortrait
@onready var player_portrait_shadow:TextureRect = $PlayerPortrait/Shadow
@onready var text:RichTextLabel = $TextBoxMargin/TextPanel/TextContainer/Text
@onready var character_name:RichTextLabel = $TextBoxMargin/TextPanel/TextContainer/NameMargin/Name
@onready var textbox_panel = $TextBoxMargin


const portrait_path:String = "res://Assets/Sprites/Portraits/"
const player_character:String = "none"

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
var lines = [] 
# ====

@export var characters_info:Dictionary = {
	"protag":{"speed":40,"name":"Andrea","pitch":0.97},
	"alix":{"speed":25,"name":"Alix","pitch":1.03},
	"eulalie":{"speed":45,"name":"Eulalie","pitch":1.05},
	"lucien":{"speed":35,"name":"Lucien","pitch":1},
	"paul":{"speed":40,"name":"Paul","pitch":0.95},
	"theodore":{"speed":40,"name":"Théodore","pitch":0.96},
}

@export var characters_font:Dictionary[String,FontFile] = {

}
@export var default_font:Font = null

var met:Array = []

var tween : Tween # Tween pour les animations

var old_character_visible = -1

func _ready() -> void:
	pass
	
	
func _process(delta):
	if animate_text:
		if text.visible_ratio < 1:
			text.visible_ratio += (1.0/text.text.length()) * (anim_speed * delta)
			if old_character_visible != text.visible_characters:
				old_character_visible = text.visible_characters
				if text.visible_characters%3 == 0:
					$CharacterSoundEffect.play()
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
	previous_character = ""
	display_line(lines[index])

func display_line(line: Dictionary):
	if characters_info.has(line["character"]):
		var path = get_portrait_path(line["character"],line["emotion"])
		var texture:Texture2D = load(path) # Chargement de la texture du portrait pour le TextureRect
		portrait.texture = texture
		portrait_shadow.texture = texture
		if line["character"] == "protag" || line["character"] in met:
			portrait.modulate = Color(1,1,1,1)
		else:
			portrait.modulate = Color(0.11, 0.11, 0.11, 1.0)
		
		$CharacterSoundEffect.pitch_scale = characters_info[line["character"]]["pitch"]
	else:
		$CharacterSoundEffect.pitch_scale = 1
		portrait.texture = null
		portrait_shadow.texture = null
	
	if line.has("character_name"):
		character_name.text = line["character_name"] # Changement nom du perso
	else:
		character_name.text = characters_info[line["character"]]["name"]
	text.text = line["text"] # Changement contenu du texte
	
	if line.has("properties"):
		if "unskip" in line["properties"]:
			unskip = true
		else:
			unskip = false
	
	if line.has("speed"): # Vitesse animation
		anim_speed = line["speed"]
	else:
		if characters_info.has(line["character"]):
			anim_speed = characters_info[line["character"]]["speed"]
		else:
			anim_speed = DEFAULT_SPEED
			
		
	start_typewriter()
	
	if line["character"] != previous_character:
		previous_character = line["character"]
		textbox_animation()

func switch_to_left(texture:Texture2D):
	portrait.show()
	portrait.texture = texture
	portrait_shadow.texture = texture # Changement portrait
	# player_portrait.texture=null
	player_portrait.hide()
	character_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func switch_to_right(texture:Texture2D):
	player_portrait.show()
	player_portrait.texture = texture
	player_portrait_shadow.texture = texture # Changement portrait
	# portrait.texture=null
	portrait.hide()
	character_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	
	

func textbox_animation() -> void:
	textbox_panel.pivot_offset_ratio = Vector2(0,0.5)
	
	tween = create_tween()
	tween.tween_property(textbox_panel, "scale:y", 0, 0)
	tween.tween_property(textbox_panel, "scale:y", 1, 0.2)
	
	var portrait_tween = create_tween()
	portrait_tween.tween_property(portrait, "position:x", -30, 0)
	portrait_tween.tween_property(portrait, "position:x", 0, 0.2)

		
signal end_dialog()
