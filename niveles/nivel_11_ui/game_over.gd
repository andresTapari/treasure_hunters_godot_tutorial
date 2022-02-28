extends WindowDialog

# Señales:
# signal hide_hud(_value) 	# ui_hud->handle_hide_hud()

# Nodos:
onready var score_label = get_node('MarginContainer/VBoxContainer/HBoxContainer/Label_score')
onready var time_label  = get_node('MarginContainer/VBoxContainer/HBoxContainer2/Label_time')

# Variables:
var exit_enable: bool = true	# Permite cerrar la ventana y que vuelva aparecer

func _ready() -> void:
	pass
#	call_deferred("popup_centered")
#	popup_centered()

# Esta funcion se ejecuta cuando se esta por mostrar la ventana:
func _on_game_over_dialog_about_to_show() -> void:
	get_tree().paused = true
	score_label.text  = String(GLOBAL.score)
	time_label.text   = format_time(GLOBAL.current_time)
	

func format_time(elapsed: int) -> String:
	# warning-ignore: INTEGER_DIVISION
	var minutes: int = int(float(elapsed / 60))
#	minutes = minutes / 60
	var seconds = elapsed % 60
	#minutes = minutes % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	return str_elapsed

func _on_game_over_dialog_popup_hide() -> void:	
	if !exit_enable:
		call_deferred("popup_centered")
	else:
		get_tree().paused = false

func _on_Button_load_pressed() -> void:
	$load_game_dialog.current_mode_save = false
	$load_game_dialog.popup_centered()

func _on_Button_restart_pressed() -> void:
	exit_enable = true
	# Llamamos a la funcion dentro de global start_new_game
	GLOBAL.start_new_game()


func _on_Button_main_pressed() -> void:
	exit_enable = true
	GLOBAL.change_current_scene('res://niveles/nivel_11_ui/main_menu.tscn')


func _on_Button_exit_pressed() -> void:
	# Salimos del juego
	get_tree().quit()


func _on_game_over_dialog_hide():
	pass
#	popup_centered()
