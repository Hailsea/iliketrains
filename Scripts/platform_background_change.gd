extends Node2D

var element:Dictionary={"last":"Background","mere_fille":false,"train":false,"carte":false,"homme":false,"banc":false,"distributeur":false}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(element_hovered())
	pass


func update_hover(nom: String,action: bool) -> void:
	element["last"]=nom
	element[nom]=action

func on_Background() -> bool:
	for i in element:
		if i=="last": continue
		if element[i]: return false
	return true
	
func element_hovered() -> String:
	if on_Background(): return "Background"
	return element["last"]

func _on_mere_fille_mouse_entered() -> void:
	update_hover("mere_fille",true)
	
func _on_mere_fille_mouse_exited() -> void:
	update_hover("mere_fille",false)


func _on_train_ouvert_mouse_entered() -> void:
	update_hover("train",true)


func _on_train_ouvert_mouse_exited() -> void:
	update_hover("train",false)


func _on_carte_mouse_entered() -> void:
	update_hover("carte",true)


func _on_carte_mouse_exited() -> void:
	update_hover("carte",false)


func _on_homme_fuyant_mouse_entered() -> void:
	update_hover("homme",true)


func _on_homme_fuyant_mouse_exited() -> void:
	update_hover("homme",false)


func _on_banc_mouse_entered() -> void:
	update_hover("banc",true)


func _on_banc_mouse_exited() -> void:
	update_hover("banc",false)


func _on_distributeur_mouse_entered() -> void:
	update_hover("distributeur",true)


func _on_distributeur_mouse_exited() -> void:
	update_hover("distributeur",false)
