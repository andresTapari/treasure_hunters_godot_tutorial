extends WindowDialog

signal done # WindowDialog_save->handle_done_signal

export var self_indx: int 

onready var button_slot_1 = get_node("VBoxContainer/HBoxContainer2/MarginContainer")
onready var button_slot_2 = get_node("VBoxContainer/HBoxContainer2/MarginContainer2")
onready var button_slot_3 = get_node("VBoxContainer/HBoxContainer2/MarginContainer3")

var current_mode_save: bool = true
var saved_data: Array

func _ready() -> void:
	button_slot_1.connect("button_pressed",self,"handle_button_pressed")
	button_slot_2.connect("button_pressed",self,"handle_button_pressed")
	button_slot_3.connect("button_pressed",self,"handle_button_pressed")
	
	
func handle_button_pressed(_index,_empty)->void:
	if _empty:
		$WindowDialog_name.line_edit.text = ""
		$WindowDialog_name.popup_centered()
		yield($WindowDialog_name,'hide')
		if !$WindowDialog_name.name_file.empty():
			print($WindowDialog_name.name_file)
			# Aca guardamos
			GLOBAL.save_data(_index,$WindowDialog_name.name_file)
			emit_signal('done')
			hide()
	else:
		$WindowDialog_name.line_edit.text = saved_data[_index-1]["slot_name"]
		$WindowDialog_name.popup_centered()
		yield($WindowDialog_name,'hide')
		if !$WindowDialog_name.name_file.empty():
			print($WindowDialog_name.name_file)
			# Aca guardamos
			GLOBAL.save_data(_index,$WindowDialog_name.name_file)
			emit_signal('done')
			hide()

func _on_Button_pressed() -> void:
	emit_signal('done')
	hide()

func _on_WindowDialog_about_to_show() -> void:
	saved_data = GLOBAL.check_saved_data()
	if !saved_data[0].empty():
		button_slot_1.update_data(saved_data[0])
	if !saved_data[1].empty():
		button_slot_2.update_data(saved_data[1])
	if !saved_data[2].empty():
		button_slot_3.update_data(saved_data[2])
