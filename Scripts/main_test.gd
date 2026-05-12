extends Node

@onready var dialog:Control = $UI_Elements/DialogUI;
@onready var choices_ui:Control = $UI_Elements/ThinkUI;

var in_event:bool = false
var loaded_event:String = ""
var dialog_data:Dictionary = {
	"triggers" : {
		"distributeur":[
			{"condition":{"episode":["coucou"],"item":[]}, "event":"dialogue1"},
			{"condition":{"episode":[],"item":[]}, "event":"dialogue2"}
		]
	},
	"events":{
		"dialogue1": [
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
		],
		"dialogue2": [
			{"type":"line","text":
				[
					{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Dialogue2 1","properties":[]},
					{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"Dialogue2 2","properties":[]},
				]
			},
			{"type":"choice","choices":
				[
					{"condition":{"episode":[],"item":[]}, "text":"AGROUGROU", "event":"agrou"},
					{"condition":{"episode":[],"item":[]}, "text":"AGROUGROUGROU", "event":"agrou2"},
					{"condition":{"episode":["coucou"],"item":[]}, "text":"AGROU", "event":"agrou3"},
				]
			}
		],
		"agrou": [
			{"type":"line","text":
				[
					{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"agrou 1","properties":[]},
				]
			},
		],
		"agrou2": [
			{"type":"line","text":
				[
					{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"agrou 2","properties":[]},
				]
			},
		],
		"agrou3": [
			{"type":"line","text":
				[
					{"character":"mishima","emotion":"neutral","character_name":"Mishima","text":"agrou 3","properties":[]},
				]
			},
		]
	}
}

var player_data:Dictionary = {
	"episodes":[],
	"items":[]
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_trigger("distributeur")

func load_trigger(trigger:String):
	if not dialog_data["triggers"].has(trigger):
		print("No trigger");
	
	var events_list = dialog_data["triggers"][trigger]
	for event in events_list:
		if verify_condition(event["condition"]):
			await process_event(event["event"])
		
func verify_condition(condition):
	for episode in condition["episode"]:
		if episode not in player_data["episodes"]: return false
	for item in condition["item"]:
		if item not in player_data["item"]: return false
	return true
	
func process_event(event:String):
	if not dialog_data["events"].has(event):
		print("No event")
	
	in_event = true
	var actions_list = dialog_data["events"][event]
	for action in actions_list:
		await process_action(action) 
	
	in_event = false
	print("Fin de l'event " + event)

func process_action(action:Dictionary):
	if action["type"] == "line":
		await load_dialog(action["text"])
	elif action["type"] == "print":
		print(action["parameter"])
	elif action["type"] == "choice":
		await load_choices(action["choices"])
		

func load_dialog(lines):
	dialog.load_lines(lines)
	dialog.show()
	await dialog.end_dialog
	dialog.hide()


func load_choices(choices):
	var choices_to_set = [null,null,null]
	for i in range(3):
		if choices[i] != null:
			if verify_condition(choices[i]["condition"]):
				choices_to_set[i] = choices[i]["text"]
	choices_ui.set_choices(choices_to_set)
	choices_ui.show()
	var final_choice = await choices_ui.choice_done
	choices_ui.hide()
	
	process_event(choices[final_choice]["event"])
	
	
		
