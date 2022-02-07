extends KinematicBody2D

# Variables:
export (int) var speed 		= 350			# Velocidad de movimiento
export (int) var jump_speed = -500			# Velocidad de salto
export (int) var gravity 	= 1000			# Aceleracion de la gravedad

var velocity = Vector2.ZERO				# Vector velocidad

func _physics_process(delta):				# <- Se ejecuta una vez por cada proceso fisico
	# Inicializamos el vector velocidad en [x=0,y=y]
	velocity.x = 0 			

	if Input.is_action_pressed("ui_right"):
		# si "ui_right" es presionado [x = speed,y=y]
		velocity.x += speed
	if Input.is_action_pressed("ui_left"):
		# si "ui_left" es presionado [x = -speed,y=y]
		velocity.x -= speed 

	if Input.is_action_just_pressed("ui_up"):
		# si Player esta sobre el suelo
		if is_on_floor():
			# si "ui_ip" es presionado [x=x,y = jump_speed]
			velocity.y = jump_speed
	# agregamos velocidad de la gravedad por factor de tiempo "delta"
	velocity.y += gravity * delta	
	# movemos a player
	velocity = move_and_slide(velocity, Vector2.UP)
