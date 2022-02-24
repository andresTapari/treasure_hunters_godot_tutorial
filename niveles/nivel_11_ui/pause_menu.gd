extends WindowDialog

# Señales:
signal hide_hud(_value) 	# ui_hud->handle_hide_hud()

# Nodos:
onready var load_game_dialog = get_node("WindowDialog_save")
onready var setup_dialog	 = get_node("setup_dialog")

var start_time:  int = 0			# Tiempo a partir que esta ventana aparece
var finish_time: int = 0			# Tiempo cuando esta ventana desaparece

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	# si se presiona el boton de pausa:
	if event.is_action_pressed('ui_pause'):
		# Evaluamos si el juego esta en pausa, si no lo esta:
		if !get_tree().paused:
			# guardamos el tiempo cuando esta ventana aparece
			start_time = OS.get_unix_time()
			# emitimos señal para ocultar el HUD
			emit_signal('hide_hud',true)
			# mostramos esta ventana
			popup_centered()
			# y pausamos el juego
			get_tree().paused = true
		# si estaba en pausa:
		else:
			 # llamamos a la funcion del boton continuar:
			_on_Button_continue_pressed()

func _on_Button_continue_pressed() -> void:
	# quitamos la pausa
	get_tree().paused = false
	# escondemos la ventana
	hide()
	# emitimos señal para mostrar el HUD
	emit_signal('hide_hud',false)

func _on_Button_restart_lvl_pressed() -> void:
	# reiniciamos el nivel
	# warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().reload_current_scene()

func _on_Button_setup_pressed() -> void:
	# emitimos señal para mostrar el HUD
	setup_dialog.popup_centered()

func _on_Button_load_game_pressed() -> void:
	# establecemos el modo de funcionamiento de la ventana como carga
	load_game_dialog.current_mode_save = false
	# mostramos la ventana cargada en el centro
	load_game_dialog.popup_centered()

func _on_Button_main_menu_pressed() -> void:
	GLOBAL.change_current_scene('res://niveles/nivel_11_ui/main_menu.tscn')

func _on_Button_exit_game_pressed() -> void:
	# Salimos del juego
	get_tree().quit()

func _on_pause_menu_popup_hide() -> void:
	# Guardamos el tiempo cuando esta ventana se esconde
	finish_time = OS.get_unix_time()
	# Establecemos el tiempo de pausa
	GLOBAL.paused_time += finish_time - start_time
	_on_Button_continue_pressed()
