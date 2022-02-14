extends Node

# Transicion de niveles:
var next_lvl_door_indx: int = -1			# Indice de puerta donde aparecer
											# -1 si no usa una puerta. (main_lvl)
var picked_items: Array = []				# Lista de items conseguidos
var score: int = 0							# Puntaje
var total_health: int = 10					# Vida Total
var health: int = 10						# Vida acutal

func add_to_picked_item_list(_id:String) -> void:
	picked_items.push_front(_id)
