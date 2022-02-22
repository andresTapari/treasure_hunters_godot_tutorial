extends WindowDialog

func _ready() -> void:
	# Conectamos la señal de la ventana de dialogo slot con handle_done_signal
	# warning-ignore:RETURN_VALUE_DISCARDED
	$WindowDialog_slot.connect("done",self,"handle_done_signal")

# Esta funcion se ejecuta cuando precionamos el boton SI
func _on_Button_yes_pressed() -> void:
	# Hacemos aparerer la ventana de dialogo popup_centered
	$WindowDialog_slot.popup_centered()

# Esta funcion se ejecuta cuando precionamos el boton No
func _on_Button_no_pressed() -> void:
	# Ocultamos la ventana
	hide()

# Esta funcion se ejecuta cuando se oculta la ventana
func _on_WindowDialog_save_popup_hide() -> void:
	# Desactivamos la pausa
	get_tree().paused = false

# Esta funcion se ejecuta cuando recibe una señal de las ventanas hijas
func handle_done_signal()->void:
	# Ocultamos la ventana
	hide()
