extends Node

@export var events_file:String
@onready var dialog:Control = $UI_Elements/DialogUI;
@onready var choices_ui:Control = $UI_Elements/ThinkUI;

var in_event:bool = false
var loaded_event:String = ""
var dialog_data:Dictionary
var default_trigger:String
var setting:String
var thoughts:Dictionary

var player_data:Array = []
var scene_background
var current_scene_elements:Array=[]
var current_scene_background

var scenes:Dictionary[String,Node2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	scenes={"quai":$Platform_background,"metro":$Metro_background}
	load_scene_events()
	$UI_Elements/Thoughts.update_text("neutral","salut")
	if default_trigger != "none":
		load_trigger(default_trigger)
	#load_trigger("alix")
	#scene_background[scene_type].show_tree("---------START")

	
func load_scene_events():
	var file = events_file
	var json_as_text = FileAccess.get_file_as_string(file)
	var data = JSON.parse_string(json_as_text)
	dialog_data = data["events"]
	setting = data["setting"]
	default_trigger = data["default_trigger"]
	var elements = dialog_data["triggers"].keys()
	print(elements)
	change_scene(setting,elements)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not in_event:
			var element = $Platform_background.element_hovered()
			in_event = true
			$Camera2D.lock = true
			load_trigger(element)
	if Input.is_key_pressed(KEY_R):
		print("----------------------------------------------------------------------R")
		change_scene("environnement_exterieur_sansmetro",["Pub","Distributeur_arriere","Garcon","Banc"])
	if Input.is_key_pressed(KEY_T):
		print("----------------------------------------------------------------------T")
		change_scene("environnement_exterieur_sansmetro",["Pub","Distributeur_avant","Banc","Metro_ouvert","Porte_ouverte"])
	if Input.is_key_pressed(KEY_Y):
		print("----------------------------------------------------------------------Y")
		switch_door()
	if Input.is_key_pressed(KEY_U):
		print("----------------------------------------------------------------------T")
		change_scene("environnement_metro_interne_ouvert",["Portes_metro_interieur","Metro_carte","Homme_debout"])
	

func load_trigger(trigger:String):
	if not dialog_data["triggers"].has(trigger):
		print("No trigger");
		return null
	
	var events_list = dialog_data["triggers"][trigger]
	for event in events_list:
		if verify_condition(event["condition"]):
			process_event(event["event"])
			break
		
func verify_condition(condition):
	for episode in condition:
		if episode not in player_data: return false
	return true
	
func process_event(event:String):
	$UI_Elements/Thoughts.hide()
	$UI_Elements/Phone.hide()
	if not dialog_data["events"].has(event):
		print("No event")
	
	in_event = true
	var actions_list = dialog_data["events"][event]
	var next = null
	for action in actions_list:
		next = await process_action(action) 
	
	in_event = false
	$Camera2D.lock = false
	$UI_Elements/Thoughts.show()
	$UI_Elements/Phone.show()
	
	if next != null:
		load_trigger(next)

func process_action(action:Dictionary):
	if action["type"] == "line":
		await load_dialog(action["text"])
	elif action["type"] == "print":
		print(action["parameter"])
	elif action["type"] == "choice":
		await load_choices(action["choices"])
	elif action["type"] == "silence":
		$EventDelay.wait_time = action["time"]
		$EventDelay.start()
		await $EventDelay.timeout
	elif action["type"] == "sceneload":
		var toload = scenes[action["scene"]]
		change_scene(toload["background"],toload["elements"])
		load_scene_events()
	elif action["type"] == "flashback":
		pass 
	elif action["type"] == "add_save":
		player_data.push_back(action["episode"])
	elif action["type"] == "trigger":
		return action["trigger"]
	
	return null
		

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

func change_scene(Background:String, Elements:Array):
	current_scene_elements=Elements
	current_scene_background=Background
	print(Background)
	var background_node
	if Background == "quai": 
		scenes["quai"].show()
		scenes["metro"].hide()
	else: 
		assert(Background == "metro","ASSERT : if else de change_scene incorrect")
		scenes["quai"].hide()
		scenes["metro"].show()
	background_node=scenes[setting]
	background_node.change_elements(Background,Elements)
	background_node.show_tree("-------------------------------Children")

#bool=true -> ajouter un élément
#bool=false -> enlever un élément
func single_change_scene(element:String,mode:bool):
	if mode:
		current_scene_elements.append(element)
	else:
		current_scene_elements.erase(element)
	change_scene(current_scene_background,current_scene_elements)

func switch_door():
	print(setting)
	scenes[setting].switch_doors()
	
func phone_up():
	print("up")
	var tween = create_tween()
	tween.tween_property($UI_Elements/Phone,"position:x",-56,0.5)

func phone_down():
	print("down")
	var tween = create_tween()
	tween.tween_property($UI_Elements/Phone,"position:x",-356,0.5)

func hover_ui(nom) -> void:
	$UI_Elements/Thoughts.update_text("neutral",nom)
