extends Node2D



var interactive_element:Dictionary={"last":"Background"}
var current_element:String=interactive_element["last"]
var scene_instances:Dictionary[String,PackedScene]={}
var backgrounds:Dictionary[String,PackedScene]={}
var open:bool=false

func _instantiate() -> void:
	pass

func _ready() -> void:
	for i in ["environnement_exterieur_sansmetro"]:
		var sprite_node = Sprite2D.new()
		sprite_node.texture = load("res://Assets/Backgrounds/"+i+".png")
		var scene = PackedScene.new()
		scene.pack(sprite_node)
		backgrounds[i]=scene
	#Metro et porte DOIVENT etre les 1er et 2eme éléments (nodes d'indice 1 et 2)
	for i in ["Metro_ferme","Metro_ouvert","Porte_ouverte","Distributeur_arriere", "Pub","Carte","Banc","Distributeur_avant","Metro_ouvert","Mere_fille","Garcon"]:
		scene_instances[i]=load("res://Scenes/Interactive_elements/"+i+".tscn")
	remove_elements()
	

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
	update_hover_ui.emit()
	
signal update_hover_ui()

func on_Background() -> bool:
	for i in interactive_element:
		if i=="last": continue
		if interactive_element[i]: return false
	return true
	
func element_hovered() -> String:
	if on_Background(): return "Background"
	return interactive_element["last"]

func change_elements(background: String, elements: Array) -> void:
	#get_child(0).texture=load("res://Assets/SI28_metro_assets/"+background+".png")
	open=false
	print("-------------------------------------------------debut_instanciation")
	var children:Dictionary[String,Node2D]={}
	var children_index=0
	remove_elements()
	show_tree("---------------------------------POST DELETE")
	for i_string in scene_instances:
		if i_string in elements:
			if i_string=="Porte_ouverte": open=true
			if i_string in children:
				children_index+=1
			else:
				create_node_from_instances(i_string,-1)
			print(i_string)
			print(open)
	print("-------------------------------------------------fin_instanciation")

func switch_doors():
	if (!get_child(1).name.contains("Metro")): 
		print("Pas de métro")
		show_tree("-----------------NO TRAIIIIIIIIIN")
		return
	assert(get_child(1).name.contains("Metro"),"Pas de metro")
	if open==true:
		get_child(2).free()
		get_child(1).free()
		create_node_from_instances("Metro_ferme",1)
	else:
		assert(open==false,"ASSERT : open variable invalid")
		get_child(1).free()
		create_node_from_instances("Metro_ouvert",1)
		create_node_from_instances("Porte_ouverte",2)
	open=!open
	print(open)
	return

func create_node_from_instances(name:String,place:int):
	add_child(scene_instances[name].instantiate())
	get_child(-1).name=name
	if place!=-1: move_child(get_child(-1),place)

func show_tree(balise):
	print(balise)
	for i in get_children():
		print(i.name)
	print(balise)
	
func remove_elements():
	print("===========REMOVE===============")
	for i in get_children():
		print("analyse:"+i.name)
		if i!=get_child(0):
			i.free()
		show_tree("___")
	print("===========REMOVE===============")
