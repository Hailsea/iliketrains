extends Node

@onready var dialog:Control = $UI_Elements/DialogUI;
@onready var choices_ui:Control = $UI_Elements/ThinkUI;

var in_event:bool = false
var loaded_event:String = ""
var dialog_data:Dictionary

var player_data:Dictionary = {
	"episodes":[],
	"items":[]
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = $Platform_background.events_file
	print(file)
	var json_as_text = FileAccess.get_file_as_string(file)
	dialog_data = JSON.parse_string(json_as_text)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not in_event:
			var element = $Platform_background.element_hovered()
			in_event = true
			load_trigger(element)
			
		

func load_trigger(trigger:String):
	print(dialog_data)
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
	$UI_Elements/Thoughts.show()

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
	
	
		


func _on_platform_background_update_element_hovered() -> void:
	$UI_Elements/Thoughts/Texte.text = $Platform_background.element_hovered()
