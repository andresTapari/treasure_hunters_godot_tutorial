extends RigidBody2D


# Nodos:
onready var animatedSprite = get_node('AnimatedSprite')
onready var rayCast_front  = get_node("RayCast_available_ground_front")
onready var rayCast_back   = get_node("RayCast_available_ground_back")
onready var rayCast_fov    = get_node("RayCast_fov")
onready var timer          = get_node("Timer")
onready var debug_label    = get_node("Label")
onready var dialog         = get_node("character_dialog")
onready var area2D         = get_node("Area2D")

# Constante:
# Estados posibles del enemigo:
enum state {idle,				# Estar
			patrol,				# Patrulla una zona, se mueve A->B y B->A
			chase,				# Persigue al jugador si entra en su campo de vision
			anticipation,		# Anticipacion antes del ataque, se puede cancelar si es atacado
			atack,				# Ataca al jugar, no se puede cancelar
			hurt,				# estado dodne persibe daño
			dead				# estado donde la unidad muere
			}

# Variables:
export var life 			= 10				# Cantidad de vida que posee
export var force_factor		= 45				# Fuerza de nock-back
export var speed			= 150				# Velocidad de movimiento
export var damage			= 2
export var fov_lenght		= 150				# Alcanze de deteccion
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
		rayCast_fov.cast_to=Vector2(fov_lenght,0)
		set_current_state(state.idle)
	else:
		print_debug("WARNING: PATROL TARGETS ARE EMPTY!!!")

func _physics_process(delta: float) -> void:
	match current_state:
		# Estador estar:
		state.idle:
			if life <= 0:
				return
			# Identificamos el estado actual:
			debug_label.text = "IDLE"
			# Reproducimos animacion de estar:
			animatedSprite.play("idle")
			# Ponemos la velocidad a cero
			linear_velocity.x = 0
			# Determinamos el tiempo a esperar en modo idle
			
			if timer.is_stopped() and life > 0:
				# Si el timer esta detenido:
				# Aleatoriza la semilla
				randomize()
				# Determinamos el tiempo a esperar entre t_min y t_max
				var seconds_to_wait = rand_range(min_t_to_wait,max_t_to_wait)
				# establecemos el tiempo
				timer.wait_time = seconds_to_wait
				# comenzamos el timer
				timer.start()
			# Chequeamos ver al jugador
			var collider = check_ray_cast()
			# Si el collider es valido
			if collider:
					target_to_chase = collider
					# ponemos el estado actual en perseguir
					set_current_state(state.chase)
					# salimos del estado
					return

		# Estado patrullar:
		state.patrol:
			# Identificamos el estado actual:
			debug_label.text = "PATROL"
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
			var collider = check_ray_cast()
			# Si el collider es valido
			if collider:
					# establecemos el objetivo a perseguir:
					target_to_chase = collider
					# ponemos el estado actual en perseguir
					set_current_state(state.chase)
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
				set_current_state(state.idle)

		# Estado perseguir:
		state.chase:
			# Identificamos el estado actual:
			debug_label.text = "CHASE"
			# Chequeamos ver al jugador
			rayCast_fov.force_raycast_update()
			# Creamos la variable collider donde alojar al jugador
			var collider
			# Si ya tiene target a seguir
			if target_to_chase:
				# Si el objetivo se encuentra fuera del rango de vision
				if position.distance_to(target_to_chase.position) > fov_lenght:
					# anulamos el target a perseguir
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
						if life > 0:
							# Establecemos nuevo estado
							set_current_state(state.anticipation)
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
					# Movemos el personaje hacia el jugador:
					linear_velocity.x = speed * dir_cof
				else:
					# Establecemos estado IDLE
					set_current_state(state.idle)
			
		state.anticipation:
			debug_label.text = "ANTICIPATION"
			# Reproducimos animacion
			animatedSprite.play("anticipation")
			# Esperamos que la animacion termine
			yield(animatedSprite,"animation_finished")
			# Cambiamos el estado actual
			set_current_state(state.atack)

		state.atack:
			dialog.set_dialog("Dead_In")
			# Identificamos el estado actual:
			debug_label.text = "ATTACK"
			# Si ataque esta deshabilitado
			if !atack_enable:
				# Salimos del estado atacar
				return
			# desabilitamos atacar, (con esto forzamos que despues de 
			# cada ataque vuelva al estado chase)
			atack_enable = false
			# actualizamos las colisiones del raycast
			rayCast_back.force_raycast_update()
			# alojamos collider raycast posterior
			var collider = rayCast_back.get_collider()
			# evaluamos si el collider es valido 
			if collider:
				# si el collider es el grupo "player"
				if collider.is_in_group("player"):
					# llama a la función hit
					collider.hit(damage)
					# llama a la función knok back
					target_knok_back(60)
			# actualizamos las colisiones del raycast
			rayCast_front.force_raycast_update()
			# cargamos las colsiiones del raycast frontal
			collider = rayCast_front.get_collider()
			# so el collider es valido
			if collider:
				# si el collider pertecence al grupo player
				if collider.is_in_group("player"):
					# llama a la funcion hit 
					collider.hit(damage)
					# llama a la funcion knok back
					target_knok_back(60)
			# reproduce animacion attack
			animatedSprite.play("attack")
			# Esperamos que la animacion termine
			yield(animatedSprite,"animation_finished")
			# Volvemos al estado chase
			set_current_state(state.chase)

		state.hurt:
		# A la variable vida le descuenta el daño.
			if life > 0:
				animatedSprite.play("hit")
				yield(animatedSprite,'animation_finished')
				set_current_state(state.chase)
			else:
				timer.stop()
				set_current_state(state.dead)
#				current_state = state.dead
				area2D.disconnect('body_entered',self,'_on_Area2D_body_entered')
				# si ya no le queda vida
				# reproducimos la animación die
				animatedSprite.play("die")
				# desactivamos la caja de colision del rigib_body para que 
				# caiga por los limites del mapa
				$CollisionShape2D.set_deferred("disabled",true)
				# desactivamos el nodo de colsion de la caja estatica para 
				# que no interaccione con ningun objeto mientras cae
				$StaticBody2D/CollisionShape2D.set_deferred("disabled",true)
				# Esperamos a que la animacion termine
				yield(animatedSprite,"animation_finished")
				# detenemos animación
				animatedSprite.stop()
				# salimos de la función
				return

		state.dead:
			debug_label.text = "DEAD"
			timer.stop()
			dialog.visible = false
			# Bucle vacio
			return

		_: #default
			return

# Funcion Hit
func hit(_damage: int,_direction) -> void:
	# A la variable vida le descuenta el daño.
	life -= _damage
	# se carga un impulso en direccón del golpe
	self.apply_central_impulse(Vector2(_direction.x*force_factor,-100))
#	look_at_target(player)
	if _direction.x < 0:
		animatedSprite.flip_h = true
	else:
		animatedSprite.flip_h = false
	set_current_state(state.hurt)
#	current_state = state.hurt


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
		set_current_state(state.patrol)
		#current_state = state.patrol

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		target_to_chase = body
		body.hit(damage)
		target_knok_back(80)
		set_current_state(state.chase)
#		current_state = state.chase

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
	var distancia: float = _target.x - self.position.x 

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

func _on_enemy_craby_body_entered(body: Node) -> void:
	print_debug(body)
	pass # Replace with function body.

func set_current_state(_state) -> void:
	# Si el estado actual es dead:
	if current_state == state.dead:
		# salimos de la funcion
		return
	# evaluamos cual es el estado _state
	match _state:
		# si es idle:
		state.idle:
			# mostramos el dialogo "Interrogation In"
			dialog.set_dialog("Interrogation_In")
		# si es chase:
		state.chase:
			# mostramos el dialogo "Exclamation In"
			dialog.set_dialog("Exclamation_In")
		# si es anticipacion:
		state.anticipation:
			# mostramos el dialogo "Dead In
			dialog.set_dialog("Dead_In")
	# establecemos como el estado actual a _state
	current_state = _state

func check_ray_cast() -> Node:
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
			# establecemos el objetivo a perseguir:
			return collider
	return null
	
	
