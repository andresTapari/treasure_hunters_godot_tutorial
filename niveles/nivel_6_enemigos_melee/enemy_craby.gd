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
export var position_target_A: NodePath			# Coordenadas hasta donde patrullar
export var position_target_B: NodePath			# Coordenadas hasta donde patrullar
export var min_t_to_wait: int = 0				# Tiempo minimo para esperar
export var max_t_to_wait: int = 0				# Tiempo maximo para esperar

var target_to_move 		= Vector2(360,102)		# Target para moverse
var dist_tolerancia 	= 1						# Tolerancia para moverse
var current_state 		= state.idle			# Estado actual 
var dir_cof				= 1						# Coeficiente de la direccon
var patrol_target_A: Vector2					# Coordenadas hasta donde patrullar
var patrol_target_B: Vector2					# Coordenadas hasta donde patrullar
var atack_range: int 	= 55-15					# Rango de ataque

# Funcion Ready:
func _ready() -> void:
	if !position_target_A.is_empty() and !position_target_B.is_empty():
		patrol_target_A = get_node(position_target_A).position
		patrol_target_B = get_node(position_target_B).position
	else:
		print_debug("WARNING: PATROL TARGETS ARE EMPTY!!!")

func _physics_process(delta: float) -> void:
	match current_state:
		state.idle:
			# Identificamos el estado actual:
			debug_label.text = "idle"
			# Reproducimos animacion de estar:
			animatedSprite.play("idle")
			# Ponemos la velocidad a cero
			linear_velocity.x = 0
			# Determinamos el tiempo a esperar en modo idle
			if timer.is_stopped():
				randomize()
				var seconds_to_wait = rand_range(min_t_to_wait,max_t_to_wait)
#				print_debug(seconds_to_wait)
				timer.wait_time = seconds_to_wait
				timer.start()

		state.patrol:
			debug_label.text = "patrol"
			
			# Chequeamos ver al jugador:
			if dir_cof < 0:
				rayCast_fov.rotation_degrees = 180
			else:
				rayCast_fov.rotation_degrees = 0
				
			rayCast_fov.force_raycast_update()
			var collider = rayCast_fov.get_collider()
			if collider:
				if collider.is_in_group("player"):
					target_to_move = collider.position
					current_state = state.atack

			# Calculamos la distancia hacia la posicion para moverse
			var distancia:float = target_to_move.x - position.x 
			# si la distancia es mayor a la tolerancia
			if distancia < 0:
				dir_cof = -1
			else:
				dir_cof = 1
			
			if abs(distancia) > dist_tolerancia:
				linear_velocity.x = speed * dir_cof
				if dir_cof > 0:
					animatedSprite.flip_h = true
				else:
					animatedSprite.flip_h = false
				animatedSprite.play("run")
			else:
				current_state = state.idle
		state.anticipation:
			pass
		state.atack:
			debug_label.text = "atack"
			# Chequeamos ver al jugador:
			if dir_cof < 0:
				rayCast_fov.rotation_degrees = 180
			else:
				rayCast_fov.rotation_degrees = 0
			rayCast_fov.force_raycast_update()
			var collider = rayCast_fov.get_collider()
			if collider:
				if abs(collider.position.x - position.x) < atack_range :
					animatedSprite.play("attack")
					yield(animatedSprite,'animation_finished')
				else:
					animatedSprite.play("run")
					linear_velocity.x = speed * dir_cof
			else:
				current_state = state.idle
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
		body.hit(damage)
		target_knok_back(80)
		current_state = state.idle


func _on_AnimatedSprite_frame_changed() -> void:
	if animatedSprite.animation != "attack":
		return
	else:
		if animatedSprite.frame == 3:
			rayCast_back.force_raycast_update()
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
