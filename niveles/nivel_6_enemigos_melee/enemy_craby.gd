extends RigidBody2D


# Nodos:
onready var animatedSprite = get_node('AnimatedSprite')
onready var rayCast_front  = get_node("RayCast_available_ground_front")
onready var rayCast_back   = get_node("RayCast_available_ground_back")
onready var rayCast_fov    = get_node("RayCast_fov")
onready var timer          = get_node("Timer")
onready var debug_label    = get_node("Label")

# Constante:
# Estados posibles del enemigo:
enum state {idle,				# Estar
			patrol,				# Patrulla una zona, se mueve A->B y B->A
			chase,				# Persigue al jugador si entra en su campo de vision
			anticipation,		# Anticipacion antes del ataque, se puede cancelar si es atacado
			atack,				# Ataca al jugar, no se puede cancelar
			hurt				# 
			}

# Variables:
export var life 			= 10				# Cantidad de vida que posee
export var force_factor		= 45				# Fuerza de nock-back
export var speed			= 150				# Velocidad de movimiento
export var damage			= 2
export var fov_lenght		= 200				# Alcanze de deteccion
export var position_target_A: NodePath			# Coordenadas hasta donde patrullar
export var position_target_B: NodePath			# Coordenadas hasta donde patrullar
export var min_t_to_wait: int = 0				# Tiempo minimo para esperar
export var max_t_to_wait: int = 0				# Tiempo maximo para esperar

var target_to_move 		= Vector2(360,102)		# Target para moverse
var dist_tolerancia 	= 1						# Tolerancia para moverse
var current_state 		= state.idle			# Estado actual 
var dir_cof				= 1						# Coeficiente de la direccon
var atack_range: int 	= 55-15					# Rango de ataque
var atack_enable: bool  = 1						# Habilita el ataque

var patrol_target_A: Vector2					# Coordenadas hasta donde patrullar
var patrol_target_B: Vector2					# Coordenadas hasta donde patrullar
var target_to_chase: Node 						# Target del jugador

# Funcion Ready:
func _ready() -> void:
	if !position_target_A.is_empty() and !position_target_B.is_empty():
		patrol_target_A = get_node(position_target_A).position
		patrol_target_B = get_node(position_target_B).position
	else:
		print_debug("WARNING: PATROL TARGETS ARE EMPTY!!!")

func _physics_process(delta: float) -> void:
	match current_state:

		# Estador estar:
		state.idle:
			# Identificamos el estado actual:
			debug_label.text = "idle"
			# Reproducimos animacion de estar:
			animatedSprite.play("idle")
			# Ponemos la velocidad a cero
			linear_velocity.x = 0
			# Determinamos el tiempo a esperar en modo idle
			if timer.is_stopped():
				# Si el timer esta detenido:
				# Aleatoriza la semilla
				randomize()
				# Determinamos el tiempo a esperar entre t_min y t_max
				var seconds_to_wait = rand_range(min_t_to_wait,max_t_to_wait)
				# establecemos el tiempo
				timer.wait_time = seconds_to_wait
				# comenzamos el timer
				timer.start()
		# Estado patrullar:
		state.patrol:
			# Identificamos el estado actual:
			debug_label.text = "patrol"
			# Chequeamos ver al jugador:
			if dir_cof < 0:
				#Si esta viendo hacia atras, rota el raycast 180º
				rayCast_fov.rotation_degrees = 180
			else:
				# si esta viendo hacia adelante, rota el raycast hacia el frente.
				rayCast_fov.rotation_degrees = 0
			# Actualizamos la información de colision del rayo
			rayCast_fov.force_raycast_update()
			# Cargamos en una variable el collider
			var collider = rayCast_fov.get_collider()
			# Si el collider es valido
			if collider:
				# y si el collider esta en el grupo player
				if collider.is_in_group("player"):
					# la posicion hacia donde moverse es la del jugador
					target_to_move = collider.position
					# ponemos el estado actual en perseguir
					current_state = state.chase
					# salimos del estado
					return
			# Calculamos la distancia hacia la posicion para moverse
			var distancia:float = target_to_move.x - position.x 
			# si la distancia es mayor a la tolerancia
			if abs(distancia) > dist_tolerancia:
				# establecemos la direccion hacia la que se tiene que mover
				dir_cof = look_at_target(target_to_move)
				# movemos el personaje
				linear_velocity.x = speed * dir_cof
				# reproducir animacion de correr 
				animatedSprite.play("run")
			else:
				# si la distancia es menor  a la tolerancia:
				# estado actual: Idle
				current_state = state.idle

		# Estado perseguir:
		state.chase:
			# Identificamos el estado actual:
			debug_label.text = "chase"
			# Chequeamos ver al jugador
			rayCast_fov.force_raycast_update()
			# Creamos la variable collider donde alojar al jugador
			var collider
			# Si ya tiene target a seguir
			if target_to_chase:
				if position.distance_to(target_to_chase.position) > fov_lenght:
					target_to_chase = null
				# asigna target a collider:
				collider = target_to_chase
			else:
				# Si no lo tiene, asigna el primer objeto que el rayo intersecta
				collider = rayCast_fov.get_collider()
			# Si es valido
			if collider:
				dir_cof = look_at_target(collider.position)
				# Si el collider es del grupo player:
				if collider.is_in_group("player"):
					# Establece la posicion a donde moverse
					target_to_move = collider.position
					# Si la distancia es menos que el rango de ataque
					if abs(target_to_move.x - position.x) < atack_range:
						# Establecemos nuevo estado
						current_state = state.anticipation
						# Habilitamos el modo ataque
						atack_enable = true
						# Salimos del estado
						return
					else:
						# Establecemos animacion correr
						animatedSprite.play("run")
						# Movemos el personaje hacia el jugador:
						linear_velocity.x = speed * dir_cof
			else:
				# si no hay collider se mueve a la ultima posicion encontrada
				if abs(target_to_move.x - position.x) < dist_tolerancia:
					#Movemos el personaje hacia el jugador:
					linear_velocity.x = speed * dir_cof
				else:
					current_state = state.idle
			
		state.anticipation:
			debug_label.text = "anticipation"
			# Reproducimos animacion
			animatedSprite.play("anticipation")
			# Esperamos que la animacion termine
			yield(animatedSprite,"animation_finished")
			# Cambiamos el estado actual
			current_state = state.atack

		state.atack:
			# Identificamos el estado actual:
			debug_label.text = "atack"
			# Si ataque esta deshabilitado
			if !atack_enable:
				# Salimos del estado atacar
				return
			# desabilitamos atacar, (con esto forzamos que despues de 
			# cada ataque vuelva al estado chase)
			atack_enable = false
			# actualizamos las colisiones del raycast
			rayCast_back.force_raycast_update()
			# alojamos 
			var collider = rayCast_back.get_collider()
			if collider:
				if collider.is_in_group("player"):
					collider.hit(damage)
					target_knok_back(60)

			rayCast_front.force_raycast_update()
			collider = rayCast_front.get_collider()
			if collider:
				if collider.is_in_group("player"):
					collider.hit(damage)
					target_knok_back(60)

			animatedSprite.play("attack")
			# Esperamos que la animacion termine
			yield(animatedSprite,"animation_finished")
			# Volvemos al estado chase
			current_state = state.chase

		_: #default
			debug_label.text = "idle"
			animatedSprite.play("idle")

# Funcion Hit
func hit(_damage: int,_direction) -> void:
	# A la variable vida le descuenta el daño.
	current_state = state.hurt
	life -= _damage
	# se carga un impulso en direccón del golpe
	self.apply_central_impulse(Vector2(_direction.x*force_factor,-100))
	# reproducimos animacion de daño
	var current_animation = animatedSprite.animation
	animatedSprite.play("hit")
	if _direction.x < 0:
		animatedSprite.flip_h = true
	else:
		animatedSprite.flip_h = false
	yield(animatedSprite,'animation_finished')
#	animatedSprite.play("idle")
	current_state = state.idle


func _on_Timer_timeout():
	if current_state == state.idle or current_state == state.patrol:
		timer.stop()
		# Esta acción cambia el modo de timer
		var dist_to_A = abs(position.x - patrol_target_A.x)
		var dist_to_B = abs(position.x - patrol_target_B.x)
		if dist_to_A > dist_to_B:
			target_to_move = patrol_target_A
		else:
			target_to_move = patrol_target_B
		current_state = state.patrol

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		target_to_chase = body
		body.hit(damage)
		target_knok_back(80)
		current_state = state.chase


func _on_AnimatedSprite_frame_changed() -> void:
	pass
#	if animatedSprite.animation != "attack":
#		return
#	else:
#		if animatedSprite.frame == 3:
#			rayCast_back.force_raycast_update()
#			var collider = rayCast_back.get_collider()
#			if collider:
#				if collider.is_in_group("player"):
#					collider.hit(damage)
#					target_knok_back(60)
#			rayCast_front.force_raycast_update()
#			collider = rayCast_front.get_collider()
#			if collider:
#				if collider.is_in_group("player"):
#					collider.hit(damage)
#					target_knok_back(60)

func target_knok_back(_force:int)-> void:
		var tween = get_node("Tween")
		# cargamos parametro al nodo Tween
		tween.interpolate_property($StaticBody2D/CollisionShape2D.get_shape(),
		 "extents",Vector2(10,10),Vector2(_force,_force),0.05,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		# Iniciamos en nodo Tween, este hace que la caja de colision de statick body
		# aumente su tamaño, empujando al jugador, logrando generar el efecto
		# de knock back del mismo al recibir daño.
		tween.start()
		# Esperamos que tween termine
		yield(tween,'tween_all_completed')
		# Reestablecemos la dimension original
		$StaticBody2D/CollisionShape2D.get_shape().extents = Vector2(10,10)

func look_at_target(_target) -> int:
	# determinamos la direccion donde hay que moverse
	var distancia:float = _target.x - self.position.x 

	# Si el target esta a la izquierda:
	if distancia < 0:
		# Hacemos que el srpite mire hacia la izquierda
		animatedSprite.flip_h = false
		# Rota el raycast 180º
		rayCast_fov.rotation_degrees = 180
		# Retornamos -1 como coeficiente de direccion
		return  -1

	# Si el target esta a la derecha:
	# Hacemos que el srpite mire hacia la derecha
	animatedSprite.flip_h = true
	#rota el raycast hacia el frente.
	rayCast_fov.rotation_degrees = 0
	# Retornamos 1 como coeficiente de direccion
	return 1
