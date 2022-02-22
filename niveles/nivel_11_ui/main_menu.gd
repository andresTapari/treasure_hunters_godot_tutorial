extends Control

# Nodos:
## Botones:
onready var button_start = get_node("MarginContainer/HBoxContainer/VBoxContainer/Button_start")
onready var button_load  = get_node("MarginContainer/HBoxContainer/VBoxContainer/Button_load")
onready var button_setup = get_node("MarginContainer/HBoxContainer/VBoxContainer/Button_setup")
onready var button_exit  = get_node("MarginContainer/HBoxContainer/VBoxContainer/Button_exit")

## Dialogos:
onready var load_game_dialog = get_node("WindowDialog")

func _ready() -> void:
	# Creamos una variable directorio
	var directory = Directory.new();
	# Creamos una variable booleana donde alojamos el resultado de si existe el archivo de guardado 1
	var save_file_1_exist: bool = directory.file_exists(GLOBAL.SAVE_PATH_FILE_1)
	# Creamos una variable booleana donde alojamos el resultado de si existe el archivo de guardado 2
	var save_file_2_exist: bool = directory.file_exists(GLOBAL.SAVE_PATH_FILE_2)
	# Creamos una variable booleana donde alojamos el resultado de si existe el archivo de guardado 3
	var save_file_3_exist: bool = directory.file_exists(GLOBAL.SAVE_PATH_FILE_3)
	# Si existe archivo 1 o existe archivo 2 o existe archivo 3
	if save_file_1_exist or save_file_2_exist or save_file_3_exist:
		# Habilitamos el boton cargar partida
		button_load.disabled = false

# Esta funcion se ejecuta cuando se presiona el boton start:
func _on_Button_start_pressed() -> void:
	# Llamamos a la funcion dentro de global start_new_game
	GLOBAL.start_new_game()


# Esta funcion se ejecuta cuando se presiona el boton cargar:
func _on_Button_load_pressed() -> void:
	# Establecemos la ventana de dialogo en modo cargar juego
	load_game_dialog.current_mode_save = false
	# Mostramos la ventana de dialogo centrada en pantalla
	load_game_dialog.popup_centered()

# Esta funcion se ejecuta cuando se presiona el boton setup:
func _on_Button_setup_pressed() -> void:
	$setup_dialog.popup_centered()

# Esta funcion se ejecuta cuando se presiona el boton exit:
func _on_Button_exit_pressed() -> void:
	pass # Replace with function body.
