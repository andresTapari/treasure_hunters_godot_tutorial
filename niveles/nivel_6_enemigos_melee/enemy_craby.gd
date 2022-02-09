extends RigidBody2D


# Nodos:
onready var animatedSprite = get_node('AnimatedSprite')
onready var rayCast_front  = get_node("RayCast_available_ground_front")
onready var rayCast_back   = get_node("RayCast_available_ground_back")
onready var timer          = get_node("Timer")

# Constante:
enum state {idle,patrol,atack,hurt}

# Variables:
export var life 			= 10				# Cantidad de vida que posee
export var force_factor		= 45				# Fuerza de nock-back
export var speed			= 150				# Velocidad de movimiento
export var patrol_target_A: Vector2				# Coordenadas hasta donde patrullar
export var patrol_target_B: Vector2				# Coordenadas hasta donde patrullar
export var min_t_to_wait: int = 0				# Tiempo minimo para esperar
export var max_t_to_wait: int = 0				# Tiempo maximo para esperar

var target_to_move 		= Vector2(360,102)		# Target para moverse
var dist_tolerancia 	= 1						# Tolerancia para moverse
var current_state 		= state.idle			# Estado actual 
var dir_cof				= 1						# Coeficiente de la direccon

# Funcion Ready:
func _ready() -> void:
	current_state = state.patrol

func _physics_process(delta: float) -> void:
	match current_state:
		state.idle:
			# Reproducimos animacion de estar:
			animatedSprite.play("idle")
			# Ponemos la velocidad a cero
			linear_velocity.x = 0
			# Determinamos el tiempo a esperar en modo idle
			if timer.is_stopped():
				randomize()
				var seconds_to_wait = rand_range(min_t_to_wait,max_t_to_wait)
				print_debug(seconds_to_wait)
				timer.wait_time = seconds_to_wait
				timer.start()
		
		state.patrol:
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

		state.atack:
			pass
#			animatedSprite.play("")
		_:
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
	timer.stop()
	# Esta acción cambia el modo de timer
	var dist_to_A = abs(position.x - patrol_target_A.x)
	var dist_to_B = abs(position.x - patrol_target_B.x)
	if dist_to_A > dist_to_B:
		target_to_move = patrol_target_A
	else:
		target_to_move = patrol_target_B
	current_state = state.patrol
	
