extends WindowDialog

# Nodos:
onready var line_edit = get_node("VBoxContainer/HBoxContainer/LineEdit")

# Variables:
var name_file: String =""

# Funcion cuando se presiona el boton aceptar
func _on_Button2_pressed() -> void:
	name_file = line_edit.text
	hide()

# Funcion cuando se presiona el boton cancelar
func _on_Button_pressed() -> void:
	name_file = ""
	hide()
