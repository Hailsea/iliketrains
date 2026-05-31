extends Node

@onready var dialog:Control = $UI_Elements/DialogUI;
@onready var choices_ui:Control = $UI_Elements/ThinkUI;

var in_event:bool = false
var loaded_event:String = ""
var dialog_data:Dictionary

var player_data:Array = []
var scene_type="platform"
var scene_background
<<<<<<< HEAD
var scene_data:Dictionary
=======
var scenes:Dictionary[String,Node2D]
>>>>>>> changements_laurent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = $Platform_background.events_file
	scenes={"platform":get_child(0),"metro":get_child(1)}
	load_scene_events(file)
<<<<<<< HEAD
	
	var json_as_text = FileAccess.get_file_as_string(file)
	scene_data = JSON.parse_string(json_as_text)
	
	
	scene_background=preload("res://Scenes/full_scene_platform_with_templates.tscn")
	load_trigger("alix")
=======
	print(get_child(0).position)
	scene_background=preload("res://Scenes/full_scene_platform_with_templates.tscn")
	#load_trigger("alix")
	#scene_background[scene_type].show_tree("---------START")
>>>>>>> changements_laurent
	
func load_scene_events(file:String):
	var json_as_text = FileAccess.get_file_as_string(file)
	var data = JSON.parse_string(json_as_text)
	dialog_data = data["events"]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not in_event:
			var element = $Platform_background.element_hovered()
			in_event = true
			load_trigger(element)
	if Input.is_key_pressed(KEY_R):
<<<<<<< HEAD
		change_scene("full_scene_platform_with_templates",["Pub","Distributeur_arriere","Garcon","Banc"])
=======
		print("----------------------------------------------------------------------R")
		change_scene("environnement_exterieur_sansmetro",["Pub","Distributeur_arriere","Garcon","Banc"])
	if Input.is_key_pressed(KEY_T):
		print("----------------------------------------------------------------------T")
		change_scene("environnement_exterieur_sansmetro",["Pub","Distributeur_avant","Banc","Metro_ouvert","Porte_ouverte"])
	if Input.is_key_pressed(KEY_Y):
		print("----------------------------------------------------------------------Y")
		switch_door()
>>>>>>> changements_laurent

func load_trigger(trigger:String):
	if not dialog_data["triggers"].has(trigger):
		print("No trigger");
	
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
	if not dialog_data["events"].has(event):
		print("No event")
	
	in_event = true
	var actions_list = dialog_data["events"][event]
	var next = null
	for action in actions_list:
		next = await process_action(action) 
	
	in_event = false
	$UI_Elements/Thoughts.show()
	
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
		var toload = scene_data[action["scene"]]
		change_scene(toload["background"],toload["elements"])
		load_scene_events(toload["events"])
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

func change_scene(Background:String, Elements:Array[String]):
	print(Background)
	var background_node
	if Background.contains("exterieur"): 
		scene_type="platform"
		scenes["platform"].show()
		scenes["metro"].hide()
	else: 
		assert(Background.contains("metro_interne"),"ASSERT : if else de change_scene incorrect")
		scene_type="metro"
		scenes["platform"].hide()
		scenes["metro"].show()
	background_node=scenes[scene_type]
	background_node.change_elements(Background,Elements)
	background_node.show_tree("-------------------------------Children")

func switch_door():
	print(scene_type)
	scenes[scene_type].switch_doors()

func _on_platform_background_update_element_hovered() -> void:
	var tween = create_tween()
	tween.tween_property($UI_Elements/Thoughts,"scale:y",0,0)
	$UI_Elements/Thoughts/Texte.text = $Platform_background.element_hovered()
	tween.tween_property($UI_Elements/Thoughts,"scale:y",1,0.15)
