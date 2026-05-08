extends Node

@onready var dialog:Control = $UI_Elements/DialogUI;
@onready var think:Control = $UI_Elements/ThinkUI;

var dialog_data:Dictionary = {
	"events":{
		"personnage": [
			{"condition":{
				"episode":["coucou"],
				"item":[],
			},
			"actions": [
				{"type":"line","text":
					[
						{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"Salut ! Voila où j'en suis pour l'interface de dialogue, c'est pas encore très avancé mais c'est un début.","properties":["unskip"]},
						{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Ça supporte la [color=red]couleur[/color] et le rich text de Godot donc c'est sympa !","properties":[]},
						{"character":"futaba","emotion":"neutral","character_name":"Futaba","text":"Coucou ! On peut avoir plusieurs personnages !","properties":[]},
						{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Et vous savez quoi ?","properties":[]},
						{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"J'ai perdu !","properties":[],"speed":1},
						{"character":"mishima","emotion":"sad","character_name":"Mishima","text":"...","properties":[],"speed":10}
					]
				},
				{"type":"print","parameter":"yeyyyy"},
				{"type":"line","text":[{"character":"futaba","emotion":"smiling","character_name":"Futaba","text":"Nyark","properties":[]}]},
			]},
			{"condition":{
				"episode":[],
				"item":[],
			},
			"actions": [
				{"type":"line","text":
					[
						{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Dialogue alternatif","properties":[]},
						{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Dialogue alternatif ligne 2","properties":[]}
					]
				},
				{"type":"print","parameter":"coucou"}
			]}
		],
	}
}

var player_data:Dictionary = {
	"episodes":[],
	"items":[]
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_event("personnage")

func process_event(current_event:String):
	if not dialog_data["events"].has(current_event):
		print("arg")
	
	var behavior_list = dialog_data["events"][current_event]
	for behavior in behavior_list:
		if await launch_behavior(behavior): break

func launch_behavior(behavior:Dictionary):
	var is_completed = check_behavior_condition(behavior["condition"])
	if not is_completed: return false
	
	for action in behavior["actions"]:
		await process_action(action)
		
	print("end")
	

func check_behavior_condition(condition):
	for episode in condition["episode"]:
		if episode not in player_data["episodes"]: return false
	for item in condition["item"]:
		if item not in player_data["item"]: return false
	return true
	
func process_action(action:Dictionary):
	if action["type"] == "line":
		await load_dialog(action["text"])
	elif action["type"] == "print":
		print(action["parameter"])
		

func load_dialog(lines):
	dialog.show()
	await dialog.end_dialog
	dialog.hide()
	print("couille")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("dialog_think"):
		dialog.modulate = Color(0.5, 0.5, 0.5, 1.0)
		think.show()
	else:
		dialog.modulate = Color(1, 1, 1, 1.0)
		think.hide()
