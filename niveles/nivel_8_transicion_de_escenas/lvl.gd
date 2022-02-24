extends Node2D

# creamos una variable para player
onready var player = get_node('lvl_8_player')

# Variables:
export var id: String = "lvl"
export var STAGE_INDEX: int = 0

func _ready():
#	print_debug("ready_call")
	
	# Establecemos el lvl actual en el registro de GLOBAL
	GLOBAL.current_lvl = self.filename
	
	## Al iniciar un nivel actualizamos la informacion en el HUD
	# Actualizamos barra de salud
	$CanvasLayer.handle_update_health(GLOBAL.total_health, GLOBAL.health)
	# Actualizamos puntaje
	$CanvasLayer.handle_update_score(GLOBAL.score)
	# Actualizamos contador de vidas
	$CanvasLayer.handle_update_lives(GLOBAL.lives)
	
	## Señales de Player:
	# Conectamos la señal "update_score" de player con la función del HUD
	player.connect('update_score',$CanvasLayer,"handle_update_score")
	# Conectamos la señal "update_health" de player con la función del HUD
	player.connect('update_health',$CanvasLayer,"handle_update_health")
	# Conectamos la señal "update_lives" de player con la funcion del HUD:
	player.connect('update_lives',$CanvasLayer,"handle_update_lives")
	
	## Conectamos las señales de Puertas:
	# Alojamos todos los hijos del nodo en childrens
	var childrens:Array = get_children()
	# Repetimos por cada elemento en la lista childrens
	for element in childrens:
		# si el elemento esta en el grupo "door"
		if element.is_in_group("door"):
			# conectamos la señal "fade_out" a la funcion  CanvasLayer.scene_transition_fade
			element.connect('fade_out',$CanvasLayer,"scene_transition_fade")
		if element.is_in_group("save_point"):
			element.connect('hide_hud',self,"handle_hide_hud")

	# cargamos la variable global de next_lvl_door_indx, en _indx
	var _indx = GLOBAL.next_lvl_door_indx

	# si _index es mayor a -1
	if _indx > -1:
		# la posicion global del jugador sera la que devuelva la funcion get_door_position(_indx)
		player.global_position = get_door_position(_indx)

	# si hay una partida precargada
	if GLOBAL.loaded_game:
		# la posicion global del jugador sera la que tenia cuando guardo una partida
		player.global_position = GLOBAL.p_position
		# reiniciamos la bandera de juego cargado
		GLOBAL.loaded_game = false
	# limpiamos items conseguidos:

	# Si la lista picked_items no esta vacia:
	if !GLOBAL.picked_items.empty():
		# cargamos todos los hijos en una lista temporal
		var temp_list:Array = get_children()
		# repetimos por cada nodo en la lista:
		for element in temp_list:
			# si el elemento esta en el grupo "pickable"
			if element.is_in_group("pickable"):
				# si el elemeno esta en la lista "picked_items"
				if GLOBAL.picked_items.has(element.id):
					# borramos el elemento del nivel
					element.queue_free()

func get_door_position(_indx: int) -> Vector2:
	# Alojamos todos los hijos del nodo en childrens
	var childrens:Array = get_children()
	# Creamos la variable posicion
	var _position: Vector2
	# Repetimos por cada hijo del nodo
	for element in childrens:
		# si el elemento esta en el grupo puerta:
		if element.is_in_group("door"):
			# y si _indx es igual al indice de la puerta
			if _indx == element.door_indx:
				# se establece la coordenada del elemento en la variable posicion
				_position = element.global_position
	# retornamos posicion
	return _position

func _on_Area2D_body_entered(_body: Node) -> void:
	pass # Replace with function body.

func handle_hide_hud(_value:bool) -> void:
	$CanvasLayer/Control.visible = !_value
