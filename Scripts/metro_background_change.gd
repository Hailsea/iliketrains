extends Node2D

@export var events_file:String

var interactive_element:Dictionary={"last":"Background"}
var current_element:String=interactive_element["last"]
var scene_nodes:Dictionary[String,Node2D]={}
var backgrounds:Dictionary[String,Resource]={}
var open:bool=false

func _instantiate() -> void:
	pass

func _ready() -> void:
	for i in ["environnement_metro_interne_fermé","environnement_metro_interne_ouvert"]:
		backgrounds[i]=load("res://Assets/Backgrounds/"+i+".png")
	print(backgrounds)
	#remove_elements()
	#Les portes doivent être le 1er node
	for i in ["Portes_metro_interieur","Metro_carte","Homme_debout","Homme_assis"]:
		create_node_from_instance(load("res://Scenes/Interactive_elements/"+i+".tscn"),i,-1)
	for i in get_children():
		if i==get_child(0): continue
		scene_nodes[i.name]=i
		i.input_pickable=true

func connect_signals() -> void:
	for child in get_children():
		if child is StaticBody2D:
			#set les signaux
			interactive_element[child.name]=false
			child.mouse_entered.connect(update_hover.bindv([child.name,true]))
			child.mouse_exited.connect(update_hover.bindv([child.name,false]))
			#sauvegarde les scènes
			#var element = PackedScene.new()
			#for c in child.get_children():
				#c.set_owner(child)
			#element.pack(child)
			#ResourceSaver.save(element, "res://Scenes/Interactive_elements/"+child.name+".tscn")
			#print("res://Scenes/Interactive_elements/"+child.name+".tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_element=element_hovered()
	pass

func update_hover(nom: String,action: bool) -> void:
	interactive_element["last"]=nom
	interactive_element[nom]=action

func on_Background() -> bool:
	for i in interactive_element:
		if i=="last": continue
		if interactive_element[i]: return false
	return true
	
func element_hovered() -> String:
	if on_Background(): return "Background"
	return interactive_element["last"]

func change_elements(background: String, elements: Array[String]) -> void:
	if background=="environnement_metro_interne_fermé": open=false
	if background=="environnement_metro_interne_ouvert" : open=true
	get_child(0).texture=backgrounds[background]
	for i in scene_nodes.keys():
		if i in elements:
			scene_nodes[i].show()
		else:
			scene_nodes[i].hide()

func switch_doors():
	print(open)
	print("switching")
	if open==true:
		get_child(0).texture=backgrounds["environnement_metro_interne_fermé"]
		scene_nodes["Portes_metro_interieur"].hide()
	else:
		assert(open==false,"ASSERT : open variable invalid")
		get_child(0).texture=backgrounds["environnement_metro_interne_ouvert"]
		scene_nodes["Portes_metro_interieur"].show()
	open=!open

func show_tree(balise):
	print(balise)
	for i in get_children():
		print(i.name)
	print(balise)

func create_node_from_instance(instance:PackedScene,name:String,place:int):
	add_child(instance.instantiate())
	get_child(-1).name=name
	if place!=-1: move_child(get_child(-1),place)

func remove_elements():
	print("===========REMOVE===============")
	for i in get_children():
		print("analyse:"+i.name)
		if i!=get_child(0):
			i.free()
		show_tree("___")
	print("===========REMOVE===============")
