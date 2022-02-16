extends KinematicBody2D

# Variables:
export var position_target_A: NodePath			# Coordenadas hasta donde patrullar
export var position_target_B: NodePath			# Coordenadas hasta donde patrullar
export var idle_time: int   = 1					# Tiempo de espera hasta comenzar a moverse
export var travel_time: int = 2					# Duracion del recorrido entre coordenadas
export var spin_speed: int = 600				# Velocidad de giro

var patrol_target_A: Vector2 = Vector2.ZERO		# Coordenada A a donde moverse
var patrol_target_B: Vector2 = Vector2.ZERO		# Coordenada B a donde moverse
var check_top_crush: bool = false				# Bandera para revisar si aplasta a player contra el techo
var target_node: Node = null					# Nodo objetivo, player cuando se encuentra sobre la plataforma
var spin_enable: bool = false					# Bandera para habilitar la rotacion de la plataforma
var spin_to_rotate: int = 0						# Cantidad de grados a girar

func _ready() -> void:
	# Si las posiciones A y B no estan vacias:
	if !position_target_A.is_empty() and !position_target_B.is_empty():
		# Se asigna a la patrol_target_A la posision de A
		patrol_target_A = get_node(position_target_A).position
		# Se asigna a la patrol_target_A la posision de B
		patrol_target_B = get_node(position_target_B).position
		# Asignamos el tiempo de espera en el timer
		$Timer.wait_time = idle_time
		# Iniciamos el contador del timer
		$Timer.start()

func _physics_process(delta: float) -> void:
	# Revisamos si check_top_crush es verdadero
	if check_top_crush:
		# y si tiene target_node y target_node esta en el grupo player:
		if target_node and target_node.is_in_group("player"):
			# y si target_node esta colisionando con el techo:
			if target_node.is_under_ceiling():
				# llama a la funcion target node con 999 de daño
				target_node.hit(999)
	# si spin_enable esta en verdadero
	if spin_enable:
		# modifica la propiedad de rotacion con velocidad del spin y delte
		rotation_degrees += spin_speed*delta
		# si la rotacion es superior o igual a la cantidad que tiene que girar
		if rotation_degrees >= spin_to_rotate:
			# la rotacion la reinicia a cero
			rotation_degrees = 0
			# pone la bandera de rotacion en false
			spin_enable = false

# Esta funcion se llama cada vez que timer termina de contar:
func _on_Timer_timeout() -> void:
	# calculamos la distancia hacia A
	var dist_to_a: float = global_position.distance_to(patrol_target_A)
	# calculamos la distancia hacia B
	var dist_to_b: float = global_position.distance_to(patrol_target_B)
	# iniciamos una variable Vector2
	var target_position: Vector2 = Vector2.ZERO
	# si la distancia A es mas grande que B:
	if dist_to_a > dist_to_b:
		# la posicion objetivo es A
		target_position = patrol_target_A
	# si la distancia B es mas grande que A
	else:
		# la posicion objetivo es B
		target_position = patrol_target_B
	# Cargamos el nodo Tween en la variable tween
	var tween = get_node("Tween")
	# Configuramos el nodo Tween
	tween.interpolate_property(self, "global_position",
		global_position, target_position, travel_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# Iniciamos el nodo tween
	tween.start()
	# Esperamos que tween termine
	yield(tween,'tween_all_completed')
	# Cuando termina reiniciamos el $Timer
	$Timer.start()

# Esta funcion se llama cada vez que la plataforma pasa por un "spinning_poing"
func spin(_value:int) -> void:
	# establecemos la variable en verdadero
	spin_enable = true
	# establecemos la cantidad de grados a girar como _value
	spin_to_rotate = _value

# Esta funcion se llama cada vez se detecta a player debajo de la plataforma
func _on_Area2D_body_entered(body: Node) -> void:
	# Si body esta en el grupo player:
	if body.is_in_group("player"):
		# si body esta en el piso:
		if body.is_on_floor():
			# llama a la funcion hit de body con 999 de daño
			body.hit(999)
			# limipia target_node
			target_node = null
			# pone en falso la bandera check_top_crush
			check_top_crush = false

# Esta funcion se llama cada vez que se detecta a player sobre la plataforma
func _on_Area2D_top_body_entered(body: Node) -> void:
	# establece a body como target
	target_node = body
	# pone en verdadero la bandera check_top_crush
	check_top_crush = true

# Esta funcion se llama cada vez que se detecta que player sale de la plataforma
func _on_Area2D_top_body_exited(body: Node) -> void:
	# limpia el target_node
	target_node = null
	# pone en falso la bandera check_top_crush
	check_top_crush = false
