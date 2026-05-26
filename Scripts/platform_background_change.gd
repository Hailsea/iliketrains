extends Node2D

@export var events_file:String

var interactive_element:Dictionary={"last":"Background"}
var current_element:String=interactive_element["last"]
var scene_instances:Dictionary[String,PackedScene]={}
var backgrounds:Dictionary[String,PackedScene]={}

func _instantiate() -> void:
	pass

func _ready() -> void:
	for i in ["environnement_exterieur_sansmetro"]:
		var sprite_node = Sprite2D.new()
		sprite_node.texture = load("res://Assets/SI28_metro_assets/"+i+".png")
		var scene = PackedScene.new()
		scene.pack(sprite_node)
		backgrounds[i]=scene
	for i in ["Distributeur_arriere", "Pub","Carte","Banc","Distributeur_avant","Metro_ferme","Metro_ouvert","Porte_ouverte","Mere_fille","Garcon"]:
		scene_instances[i]=load("res://Scenes/Interactive_elements/"+i+".tscn")

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
	backgrounds[background].instantiate()
	for element in elements:
		scene_instances[element].instantiate()
