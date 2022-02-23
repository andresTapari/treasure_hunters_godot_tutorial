extends WindowDialog

# Señales:
signal done # WindowDialog_save->handle_done_signal

# Nodos:
onready var title_label     = get_node("VBoxContainer/Label")
onready var dialog_set_name = get_node("WindowDialog_name")
onready var button_slot_1   = get_node("VBoxContainer/HBoxContainer2/MarginContainer")
onready var button_slot_2   = get_node("VBoxContainer/HBoxContainer2/MarginContainer2")
onready var button_slot_3   = get_node("VBoxContainer/HBoxContainer2/MarginContainer3")

# Variables
var current_mode_save: bool = true				# Modo actual de la ventana 
												# True = Guardar, False = Cargar
var saved_data: Array							# Datos guardados

func _ready() -> void:
	# Conectamos las señales de los botones
	button_slot_1.connect("button_pressed",self,"handle_button_pressed")
	button_slot_2.connect("button_pressed",self,"handle_button_pressed")
	button_slot_3.connect("button_pressed",self,"handle_button_pressed")

func handle_button_pressed(_index,_empty)->void:
	# si el modo de esta ventana es para guardar:
	if current_mode_save:
		# Si este boton esta vacio:
		if _empty:
			dialog_set_name.line_edit.text = ""
			dialog_set_name.popup_centered()
			yield(dialog_set_name,'hide')
			if !dialog_set_name.name_file.empty():
				print(dialog_set_name.name_file)
				# Aca guardamos
				GLOBAL.save_data(_index,dialog_set_name.name_file)
				emit_signal('done')
				hide()
		else:
			dialog_set_name.line_edit.text = saved_data[_index-1]["slot_name"]
			dialog_set_name.popup_centered()
			yield(dialog_set_name,'hide')
			if !dialog_set_name.name_file.empty():
				print(dialog_set_name.name_file)
				# Aca guardamos
				GLOBAL.save_data(_index,dialog_set_name.name_file)
				emit_signal('done')
				hide()
	# Si el modo de la ventana es para cargar una partida:
	else:
		# LLamamos a la funcion para cargar la partida
		GLOBAL.load_saved_data(_index - 1)
		


func _on_Button_pressed() -> void:
	emit_signal('done')
	hide()

func _on_WindowDialog_about_to_show() -> void:
	if current_mode_save:
		title_label.text = "SELECT SLOT TO SAVE"
	else:
		title_label.text = "SELECT GAME TO PLAY"
	saved_data = GLOBAL.check_saved_data()
	if !saved_data[0].empty():
		button_slot_1.update_data(saved_data[0])
	if !saved_data[1].empty():
		button_slot_2.update_data(saved_data[1])
	if !saved_data[2].empty():
		button_slot_3.update_data(saved_data[2])
