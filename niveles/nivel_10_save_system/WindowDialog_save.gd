extends WindowDialog

func _ready() -> void:
	popup_centered()
	pass

func _on_Button_yes_pressed() -> void:
	$WindowDialog_slot.popup_centered()

func _on_Button_no_pressed() -> void:
	hide()
	
func _on_WindowDialog_save_popup_hide() -> void:
	get_tree().paused = false
