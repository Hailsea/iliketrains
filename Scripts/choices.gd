extends HBoxContainer

@onready var button1:Button = $HBoxContainer/ButtonsMargin/ContainerButton/Choix1
@onready var button2:Button = $HBoxContainer/ButtonsMargin/ContainerButton/Choix2
@onready var button3:Button = $HBoxContainer/ButtonsMargin/ContainerButton/Choix3
@onready var buttons = [button1,button2,button3]

const BUTTON_COUNT:int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_choices(choices_array:Array):
	for i in range(BUTTON_COUNT):
		if choices_array[i] == null:
			buttons[i].hide()
		else:
			buttons[i].show()
			buttons[i].text = choices_array[i]

	
signal choice_done()
	


func _on_choix_1_pressed() -> void:
	choice_done.emit(0) 

func _on_choix_2_pressed() -> void:
	choice_done.emit(1) 

func _on_choix_3_pressed() -> void:
	choice_done.emit(2) 
