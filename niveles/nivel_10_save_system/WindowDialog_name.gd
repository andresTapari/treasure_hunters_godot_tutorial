extends WindowDialog

var name_file: String =""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Button2_pressed() -> void:
	name_file = $VBoxContainer/HBoxContainer/LineEdit.text
	hide()

func _on_Button_pressed() -> void:
	hide()
