extends Control

# Señales:
# signal hide_hud(_value) 	# ui_hud->handle_hide_hud()

# Nodos:
onready var score_label = get_node("margin/VBoxContainer/HBoxContainer/Label_score")
onready var time_label  = get_node("margin/VBoxContainer/HBoxContainer2/Label_time")

# Variables:
var exit_enable: bool = true	# Permite cerrar la ventana y que vuelva aparecer

func _ready() -> void:
	hide()

# Esta funcion se ejecuta cuando se muestra la ventana:
func popup_centered():
	score_label.text  = String(GLOBAL.score)
	time_label.text   = format_time(GLOBAL.current_time)
	get_tree().paused = true
	visible = true

func format_time(elapsed: int) -> String:
	# warning-ignore: INTEGER_DIVISION
	var minutes: int = int(float(elapsed / 60))
#	minutes = minutes / 60
	var seconds = elapsed % 60
	#minutes = minutes % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	return str_elapsed

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

func _on_Control_hide() -> void:
	get_tree().paused = false
