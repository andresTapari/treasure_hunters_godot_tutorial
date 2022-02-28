extends Node

# Constantes:
## Descomentar esto en DEBUG:
var SAVE_PATH_FILE_1: String = "res://saves/data_1.dat"
var SAVE_PATH_FILE_2: String = "res://saves/data_2.dat"
var SAVE_PATH_FILE_3: String = "res://saves/data_3.dat"
var SAVE_PATH_DIR:    String = "res://saves/"
var THUMBNAIL_FOLDER: String = "res://thumbnail/"
var ROOT_PATH_FOLDER: String = "res://"

## Descomentar esto en RELEASE:
#var SAVE_PATH_FILE_1: String = "user://saves/data_1.dat"
#var SAVE_PATH_FILE_2: String = "user://saves/data_2.dat"
#var SAVE_PATH_FILE_3: String = "user://saves/data_3.dat"
#var SAVE_PATH_DIR:    String = "user://saves/"
#var THUMBNAIL_FOLDER: String = "user://thumbnail/"
#var ROOT_PATH_FOLDER: String = "user://"

## Contantes Generales:
var THUMBNAIL_FOLDER_NAME: String = "thumbnail"
var SAVE_FOLDER:           String = "saves"

# Nodos:
var milisecond_timer : Timer

# Transicion de niveles:
var next_lvl_door_indx: int = -1			# Indice de puerta donde aparecer
											# -1 si no usa una puerta. (main_lvl)
var timer_first_run: bool = true			# Evita que el timer se reinicie cada vez
											# que ocurra una transicion de niveles

# Datos del personaje:
var picked_items:	  Array = []			# Lista de items conseguidos
var score: 			 	int = 0				# Puntaje
var total_health: 	 	int = 10			# Salud Total
var health: 		 	int = 10			# Salud Actual
var lives:				int = 3				# Vidas del jugador
var p_position:  	Vector2 = Vector2.ZERO	# Posicion de player
var time_counter_ms:  float = 0				# Tiempo de juego transcurrido

# Sistema de guardado:
var slot_name:	 	String  = ""			# Nombre de la partida guardada
var current_lvl: 	String  = ""			# path al lvl actual
var thumbnail_path: String  = ""			# path a la minitatura del nivel
var date_time:		String  = ""			# fecha de guardado
var current_time:	int		= 0				# tiempo actual de juego
var time_offset: 	int	 	= 0				# Offset de tiempo, es el tiempo de la partida guardada anterior.
var image_buffer: 	Image					# Buffer de imagen a mostrar
var loaded_game:	bool    = false			# Bandera para indicar que se cargo 
											# un juego de una partida guardada (afecta posicion jugador)

# Otras variables:
#var paused_time: 	int = 0					# tiempo que dura la pausa (afecta a tiempo en hud y tiempo guardado)

# Archivo a guardar:
var data_to_save: Dictionary = {	
									"slot_name": slot_name,
									"current_lvl": current_lvl,
									"date": date_time,
									"current_health": health,
									"current_time": current_time,
									"current_score": score,
									"current_lives": lives,
									"player_position":p_position,
									"picked_idems": picked_items,
									"thumbnail_path":thumbnail_path
								}

var time_start: int = 0

func _ready() -> void:
	# Iniciamos el timer:
	## Creamos una clase timer:
	milisecond_timer = Timer.new()
	## Lo agregamos como hijo al nodo
	add_child(milisecond_timer)
	## Estableccemos el tiempo:
	milisecond_timer.wait_time = 0.1
	## Configuramos el modo de repeticion
	milisecond_timer.one_shot = false
	## Conecamos la señal:
	milisecond_timer.connect("timeout",self,"handle_milisecond_timer_out")
	
	# Cuando se inicia el juego:
	## Creamos clase Directorio
	var dir = Directory.new()
	## abrimos la direccion del directorio a guardar
	dir.open(ROOT_PATH_FOLDER)
	## creamos la carpeta para guardar las partidas
	dir.make_dir(SAVE_FOLDER)
	## creamos la carpeta para guardar las miniaturas
	dir.make_dir(THUMBNAIL_FOLDER)
	## eliminamos la instancia dir
	dir = null

func add_to_picked_item_list(_id:String) -> void:
	# agregamos el id del items a la lista de items recolectados
	picked_items.push_front(_id)

func save_data(_indx: int, _slot_name: String) -> void:
	# Guardar miniatura:
	## creamos la direccion donde sera guardada la miniatura 
	var image_path:String = THUMBNAIL_FOLDER + _slot_name +".png"
	## guardamos la miniatura
	# determinar la fecha:
	var _date: Dictionary    = OS.get_datetime()
	var _date_string: String = "[" + String(_date["day"])   + " / " + \
									 String(_date["month"]) + " / " + \
									 String(_date["year"])  + "]"
	date_time = _date_string
	
	# warning-ignore:RETURN_VALUE_DISCARDED
	image_buffer.save_png(image_path)
	
	# Calculamos el tiempo de partida
#	var temp_time:int = current_time - paused_time
	
	# actualizamos datos del diccionario
	data_to_save["slot_name"]		= _slot_name		# Nombre de partida
	data_to_save["current_lvl"]		= current_lvl		# Stage actual
	data_to_save["current_health"]	= health			# Salud Actual
	data_to_save["date"]			= date_time			# Guardamos la fecha 
	data_to_save["current_time"]	= current_time		# Tiempo de partida
	data_to_save["current_score"]	= score				# puntaje
	data_to_save["current_lives"]	= lives				# Total de vida actual
	data_to_save["player_position"] = p_position		# La posicion del jugador
	data_to_save["picked_idems"]	= picked_items		# Items recolectados
	data_to_save["thumbnail_path"]	= image_path		# El path con la imagen

	# Creamos la variable direccion de archivo
	var _file_path: String = "" 

	# Nos fijamos el valor del indice:
	match _indx:
		# si el indice es 1
		1:
			# cargamos el path del archivo 1
			_file_path = SAVE_PATH_FILE_1
		# si el indice es 2
		2:
			# cargamos el path del archivo 2
			_file_path = SAVE_PATH_FILE_2
		# si el indice es 3
		3:
			# cargamos el path del archivo 3
			_file_path = SAVE_PATH_FILE_3
		_: #default
			# por defecto cargamos el path del archivo 1
			_file_path = SAVE_PATH_FILE_1

	# Creamos una variable de tipo archivo
	var file:File = File.new()

	# Convertimos el diccionario al tipo string
	var data_to_save_string: = var2str(data_to_save)
	# Abrimos el archivo en modo escritura
	# warning-ignore:RETURN_VALUE_DISCARDED
	file.open(_file_path,File.WRITE)
	# Guardamos los datos
	file.store_string(data_to_save_string)
	# Cerramos el archivo
	file.close()
	# eliminamos la instancia file
	file = null

func check_saved_data() -> Array:
	# Creamos una instancia de File
	var file = File.new()
	
	# Creamos 3 variables de tipo diccionario
	var data_1:Dictionary
	var data_2:Dictionary
	var data_3:Dictionary
	
	# Abrimos la direccion de SAVE_PATH_FILE_1 en modo lectura
	# si se abre de forma exitosa
	if file.open(SAVE_PATH_FILE_1, File.READ) == OK:
		# cargamos los datos guardados en data_1
		data_1 = str2var(file.get_as_text())
	# cerramos el archivo
	file.close()
	
	# Abrimos la direccion de SAVE_PATH_FILE_2 en modo lectura
	# si se abre de forma exitosa
	if file.open(SAVE_PATH_FILE_2, File.READ) == OK:
		# cargamos los datos guardados en data_2
		data_2 = str2var(file.get_as_text())
	# cerramos el archivo
	file.close()

	# Abrimos la direccion de SAVE_PATH_FILE_3 en modo lectura
	# si se abre de forma exitosa
	if file.open(SAVE_PATH_FILE_3, File.READ) == OK:
		# cargamos los datos guardados en data_2
		data_3 = str2var(file.get_as_text())
	# cerramos el archivo
	file.close()
	# eliminamos la instancia file
	file = null
	
	# cargamos en _list los 3 diccionarios
	var _list = [data_1,data_2,data_3]
	# retornamos el Arreglo _list
	return _list

func load_saved_data(_index) -> void:
	# ponemos la bandera de partida cargada en alto
	loaded_game = true
	# 
	timer_first_run = true
	# Reiniciamos el contador de timer:
	time_counter_ms = 0
	# Iniciamos el timer:
	milisecond_timer.start()

	# Cargamos datos guardados en el disco
	var _list_saved_data =  check_saved_data() 
	# Cargamos los datos de la partida en una variable
	var disk_data: Dictionary = _list_saved_data[_index]
	# si disk_data no esta vacio:
	if !disk_data.empty():
		# Reestablecemos los datos de juego con los de la partida anterior
		current_lvl 	= disk_data["current_lvl"]
		health 			= disk_data["current_health"]
		time_offset 	= disk_data["current_time"] # esto se pasa a un offset de tiempo luego
		score 			= disk_data["current_score"]
		lives 			= disk_data["current_lives"]
		picked_items 	= disk_data["picked_idems"]
		p_position		= disk_data["player_position"]
		# Cambiamos la escena actual por la de current_lvl
		change_current_scene(current_lvl)

func change_current_scene(_lvl_path) -> void:

	#DEBUG:
#	print_debug("paused_time: ",paused_time,"\ncurrent_time:",current_time,\
#				"\noffset_time:",time_offset)
	# 0. Iniciamos el timer en el momento que cargamos la partida:
#	if loaded_game:
#		paused_time = 0
	if timer_first_run:
		time_start = OS.get_unix_time()
		timer_first_run = false
	
	#DEBUG:
	print_debug("current_time: ", current_time,"\noffset_time: ",time_offset)
	# Para cambiar escena, como no estamos cambiando una escena constante,
	# no podemos usar esta funcion directamente:
	#
	#     get_tree().set_current_scene('res://niveles/nivel_8_transicion_de_escenas/lvl_A.tscn')
	#
	# entonces debemos proceder de la siguiente forma: 
	
	# 1. Obtenemos el nodo RAIZ
	var root = get_tree().get_root()

	# 2. Obtenemos la escena actual
	var current_scene = root.get_child(root.get_child_count() - 1)
	
	# 3. Removemos la escena
	current_scene.queue_free()
	
	# 4. Cargamos la siguiente escena
	var new_scene = ResourceLoader.load(_lvl_path)
	
	# 5. Creamos una instancia de la nueva escena
	current_scene = new_scene.instance()
	
	# 6. La agregamos a la escena activa, como hija del nodo raiz
	get_tree().get_root().add_child(current_scene)

	# Opcionalmente, para hacerlo compatible
	# con la API SceneTree.change_scene().
	get_tree().set_current_scene(current_scene)

func start_new_game() -> void:
	# Reiniciamos variables del juego
	
	## Niveles:
	next_lvl_door_indx = -1		# Indice de puerta donde aparecer
	picked_items.clear()		# Items recolectados por el personaje
	
	## Personaje:
	score			= 0			# Puntaje
	total_health 	= 10		# Salud Total
	health	 		= 10		# Salud Actual
	lives			= 3			# Vidas del jugador
#	paused_time 	=  0		# Tiempo de juego en pausa
	
	# Iniciamos timer:
	## Reiniciamos la variable de conteo de segundos
	time_counter_ms = 0 
	time_offset = 0
	## Iniciamos el timer
	milisecond_timer.start()

	# Ponemos en falso la bandera del timer:
	timer_first_run = false
	# Iniciamios el timer en el momento que arrancamos la partida
	# warning-ignore:RETURN_VALUE_DISCARDED
	time_start = OS.get_unix_time()
	# Para comenzar una nueva partida cambiamos la escena actual a la siguiente:
#	get_tree().change_scene('res://niveles/nivel_x_full_walktrough/lvl_0_stage_0.tscn')
	change_current_scene('res://niveles/nivel_x_full_walktrough/lvl_0_stage_0.tscn')

func del_saved_data() -> void:
	# creamos una instancia de Directory
	var file = Directory.new()
	# removemos el archivo en la direccion de SAVE_PATH_FILE_1
	file.remove(SAVE_PATH_FILE_1)
	# removemos el archivo en la direccion de SAVE_PATH_FILE_2
	file.remove(SAVE_PATH_FILE_2)
	# removemos el archivo en la direccion de SAVE_PATH_FILE_3
	file.remove(SAVE_PATH_FILE_3)
	# removemos la instancia file
	file = null

func handle_milisecond_timer_out() -> void:
	# aumentamos el contador de tiempo 0.1"
	time_counter_ms += 0.1
