extends Node

# Constantes:
## path para modo proyecto:
var SAVE_PATH_FILE_1: String = "res://saves/data_1.dat"
var SAVE_PATH_FILE_2: String = "res://saves/data_2.dat"
var SAVE_PATH_FILE_3: String = "res://saves/data_3.dat"
var SAVE_PATH_DIR: String 	 = "res://saves/"
var THUMBNAIL_FOLDER: String = "res://thumbnail/"
var ROOT_PATH_FOLDER: String = "res://"

## Path para usuario:
#var SAVE_PATH_FILE_1: String = "user://saves/data_1.dat"
#var SAVE_PATH_FILE_2: String = "user://saves/data_2.dat"
#var SAVE_PATH_FILE_3: String = "user://saves/data_3.dat"
#var SAVE_PATH_DIR: String 	  = "user://saves/"
#var THUMBNAIL_FOLDER: String = "user://thumbnail/"
#var ROOT_PATH_FOLDER: String = "user://"

var THUMBNAIL_FOLDER_NAME: String = "thumbnail"
var SAVE_FOLDER:String	= "saves"

# Transicion de niveles:
var next_lvl_door_indx: int = -1			# Indice de puerta donde aparecer
											# -1 si no usa una puerta. (main_lvl)

# Datos del personaje
var picked_items: Array = []				# Lista de items conseguidos
var score: 			int = 0					# Puntaje
var total_health: 	int = 10				# Salud Total
var health: 		int = 10				# Salud Actual
var lives:			int = 3					# Vidas del jugador

# Sistema de guardado:
var slot_name:	 String	 = ""				# Nombre de la partida guardada
var current_lvl: String  = ""				# path al lvl actual
var current_time: int	 = 0				# tiempo actual de juego
var thumbnail_path: String  = ""			# path a la minitatura del nivel
var image_buffer: Image						# Buffer de imagen a mostrar

# Archivo a guardar:
var data_to_save: Dictionary = {	"slot_name": slot_name,
									"current_lvl": current_lvl,
									"current_health": health,
									"current_time": current_time,
									"current_score": score,
									"current_lives": lives,
									"picked_idems": picked_items,
									"thumbnail_path":thumbnail_path
								}

var time_start: int = 0

func _ready() -> void:
	var dir = Directory.new()
	dir.open(ROOT_PATH_FOLDER)
	dir.make_dir(SAVE_FOLDER)
	dir.make_dir(THUMBNAIL_FOLDER)
	time_start = OS.get_unix_time()

func add_to_picked_item_list(_id:String) -> void:
	picked_items.push_front(_id)

func save_data(_indx: int, _slot_name: String) -> void:
	# guardamos la minitatura 
	var image_path:String = THUMBNAIL_FOLDER + _slot_name +".png"
	image_buffer.save_png(image_path)
	# actualizamos datos del diccionario
	data_to_save["slot_name"]		= _slot_name
	data_to_save["current_lvl"]		= current_lvl
	data_to_save["current_health"]	= health
	data_to_save["current_time"]	= current_time
	data_to_save["current_score"]	= score
	data_to_save["current_lives"]	= lives
	data_to_save["picked_idems"]	= picked_items
	data_to_save["thumbnail_path"]	= image_path

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
			_file_path = SAVE_PATH_FILE_1

	# Creamos una variable de tipo archivo
	var file:File = File.new()
	# Convertimos el diccionario al tipo string
	var data_to_save_string: = var2str(data_to_save)
	# Abrimos el archivo en modo escritura
	file.open(_file_path,File.WRITE)
	# Guardamos los datos
	file.store_string(data_to_save_string)
	# Cerramos el archivo
	file.close()

func check_saved_data() -> Array:
	var file = File.new()
	var data_1:Dictionary
	var data_2:Dictionary
	var data_3:Dictionary
	if file.open(SAVE_PATH_FILE_1, File.READ) == OK:
		data_1 = str2var(file.get_as_text())
	file.close()
	if file.open(SAVE_PATH_FILE_2, File.READ) == OK:
		data_2 = str2var(file.get_as_text())
	file.close()
	if file.open(SAVE_PATH_FILE_3, File.READ) == OK:
		data_3 = str2var(file.get_as_text())
	file.close()
	var _list = [data_1,data_2,data_3]
	return _list

