extends Node2D

var interactive_element:Dictionary={"last":"Background"}
var current_element:String=interactive_element["last"]

func _ready() -> void:
	for child in get_children():
		if child is StaticBody2D:
			#set les signaux
			interactive_element[child.name]=false
			child.mouse_entered.connect(update_hover.bindv([child.name,true]))
			child.mouse_exited.connect(update_hover.bindv([child.name,false]))
			#sauvegarde les hitboxes
			for i in child.get_children():
				if i is CollisionPolygon2D: 
					var hitbox = PackedScene.new()
					hitbox.pack(child)
					ResourceSaver.save(hitbox, "res://Assets/Hitboxes/"+child.name+".tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_element=element_hovered()
	print(current_element)
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
