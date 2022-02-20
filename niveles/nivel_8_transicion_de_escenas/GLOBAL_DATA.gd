extends Node

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
var current_core: int	 = 0				# puntaje actual
var thumbnail_path: String  = ""			# path a la minitatura del nivel

# archivo a guardar:
var data_to_save: Dictionary = {	"slot_name": slot_name,
									"current_lvl": current_lvl,
									"current_time": current_time,
									"current_score":current_core,
									"thumbnail_path":thumbnail_path}

var time_start: int = 0

func _ready() -> void:
	time_start = OS.get_unix_time()

func add_to_picked_item_list(_id:String) -> void:
	picked_items.push_front(_id)

