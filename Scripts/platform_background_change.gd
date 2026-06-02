extends Node2D



var interactive_element:Dictionary={"last":"Background"}
var current_element:String=interactive_element["last"]
var scene_nodes:Dictionary[String,Node2D]={}
var open:bool=false

func _instantiate() -> void:
	pass

func _ready() -> void:
	get_child(0).texture = load("res://Assets/Backgrounds/quai.png")
	#Metro et porte DOIVENT etre les 1er et 2eme éléments (nodes d'indice 1 et 2)
	remove_elements()
	for i in ["Metro_ferme","Metro_ouvert","Porte_ouverte","Distributeur_arriere", "Pub","Carte","Banc","Distributeur_avant","Mere_fille","Garcon"]:
		create_node_from_instance(load("res://Scenes/Interactive_elements/"+i+".tscn"),i,-1)
	for i in get_children():
		if i==get_child(0): continue
		scene_nodes[i.name]=i
		i.input_pickable=true
	#print(scene_nodes)
	scene_nodes["Metro_ferme"].hide()
	connect_signals()

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
	update_hover_ui.emit(element_hovered())
	
signal update_hover_ui(nom)

func on_Background() -> bool:
	for i in interactive_element:
		if i=="last": continue
		if interactive_element[i]: return false
	return true
	
func element_hovered() -> String:
	if on_Background(): return "Background"
	return interactive_element["last"]

func change_elements(background: String, elements: Array) -> void:
	open="Porte_ouverte" in elements
	for i in scene_nodes.keys():
		if i in elements:
			scene_nodes[i].show()
		else:
			scene_nodes[i].hide()

func switch_doors():
	if (!get_child(1).visible && !get_child(2).visible): 
		#print("Pas de métro")
		#show_tree("-----------------NO TRAIIIIIIIIIN")
		return
	assert(get_child(1).name.contains("Metro"),"Pas de metro")
	if open==true:
		scene_nodes["Porte_ouverte"].hide()
		scene_nodes["Metro_ouvert"].hide()
		scene_nodes["Metro_ferme"].show()
	else:
		assert(open==false,"ASSERT : open variable invalid")
		scene_nodes["Porte_ouverte"].show()
		scene_nodes["Metro_ouvert"].show()
		scene_nodes["Metro_ferme"].hide()
	open=!open
	#print(open)
	return

func create_node_from_instance(instance:PackedScene, name:String,place:int):
	add_child(instance.instantiate())
	get_child(-1).name=name
	if place!=-1: move_child(get_child(-1),place)

func show_tree(balise):
	#print(balise)
	for i in get_children():
		#print(i.name)
		if i!=get_child(0): 
			print(i.visible)
			print(i.input_pickable)
	#print(balise)
	
func remove_elements():
	#print("===========REMOVE===============")
	for i in get_children():
		#print("analyse:"+i.name)
		if i!=get_child(0):
			i.free()
		#show_tree("___")
	#print("===========REMOVE===============")
