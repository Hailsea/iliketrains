extends Node

@export var events_file:String
@onready var dialog:Control = $UI_Elements/DialogUI;
@onready var choices_ui:Control = $UI_Elements/ThinkUI;
@onready var platform_background: Node2D = $Platform_background

var in_event:bool = false
var loaded_event:String = ""
var dialog_data:Dictionary
var default_trigger:String
var setting:String
var thoughts:Dictionary

var player_data:Array = []
var current_scene_elements:Array=[]
var current_scene_background

var phone:bool = false

var scenes:Dictionary[String,Node2D]




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	scenes={"quai":$Platform_background,"metro_ouvert":$Metro_background,"metro_ferme":$Metro_background}
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
	setting = data["background"]
	default_trigger = data["default_trigger"]
	thoughts = data["thoughts"]
	var elements = dialog_data["triggers"].keys()
	change_scene(data["background"],elements)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not in_event:
			var element = scenes[setting].element_hovered()
			load_trigger(element)
	if Input.is_key_pressed(KEY_R):
		change_scene("environnement_exterieur_sansmetro",["Pub","Distributeur_arriere","Garcon","Banc"])
	if Input.is_key_pressed(KEY_T):
		change_scene("environnement_exterieur_sansmetro",["Pub","Distributeur_avant","Banc","Metro_ouvert","Porte_ouverte"])
	if Input.is_key_pressed(KEY_Y):
		switch_door()
	if Input.is_key_pressed(KEY_U):
		change_scene("environnement_metro_interne_ouvert",["Portes_metro_interieur","Metro_carte","Homme_debout"])
	if Input.is_key_pressed(KEY_I):
		scenes[setting].show_tree("")

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
		return null
	
	in_event = true
	$Camera2D.lock = true
	
	var actions_list = dialog_data["events"][event]
	var next = null
	for action in actions_list:
		next = await process_action(action) 
	
	player_data.push_back(event)
	
	in_event = false
	$Camera2D.lock = false
	$UI_Elements/Thoughts.show()
	$UI_Elements/Phone.show()
	
	if next != null:
		load_trigger(next)

func process_action(action):
	if action[0] == "line":
		await load_dialog(action[1])
	elif action[0] == "print":
		print(action[1])
	elif action[0] == "choice":
		await load_choices(1)
	elif action[0] == "silence":
		$SilenceDelay.wait_time = action[1]
		$SilenceDelay.start()
		await $SilenceDelay.timeout
	elif action[0] == "scene":
		events_file = "res://Dialogs/"+action[1]+".json"
		load_scene_events()
	elif action[0] == "flashback":
		var tween = create_tween()
		tween.tween_property($White/White,"modulate:a",1,0.5)
		await tween.finished
		if action[1]:
			$Flashback.show()
		else:
			$Flashback.hide()
		tween = create_tween()
		tween.tween_property($White/White,"modulate:a",0,0.5)
		await tween.finished
	elif action[0] == "trigger":
		return action[1]
	elif action[0] == "thought":
		thoughts[action[1]] = action[2]
	elif action[0] == "doors":
		switch_door()
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
	var background_node
	if Background == "quai": 
		scenes["quai"].show()
		scenes["metro_ouvert"].hide()
	else: 
		#assert(Background == "metro","ASSERT : if else de change_scene incorrect")
		scenes["quai"].hide()
		scenes["metro_ouvert"].show()
	background_node=scenes[Background]
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
	scenes[setting].switch_doors()
	
func phone_up():
	var tween = create_tween()
	if phone:
		phone = false
		tween.tween_property($UI_Elements/Phone,"position:x",-356,0.2)
	else:
		phone = true
		if not "phone_checked" in player_data:
			player_data.push_back("phone_checked")
		tween.tween_property($UI_Elements/Phone,"position:x",-56,0.2)
	

func phone_down():
	var tween = create_tween()
	

func hover_ui(nom) -> void:
	print(nom)
	$UI_Elements/Thoughts.update_text(thoughts[nom][0],thoughts[nom][1])

func parser_json_scene_change(file:String):
	var json_as_text = FileAccess.get_file_as_string(file)
	var data = JSON.parse_string(json_as_text)
	var background_from_json=data["background"]
	var triggers=data["events"]["triggers"]
	var elements_from_json=[]
	for i in triggers.keys():
		elements_from_json.append(i)
	change_scene(background_from_json,elements_from_json)
