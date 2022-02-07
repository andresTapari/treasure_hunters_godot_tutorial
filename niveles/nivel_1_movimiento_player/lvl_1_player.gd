extends KinematicBody2D

# Variables:
export (int) var speed 		= 350			# Velocidad de movimiento
export (int) var jump_speed = -500			# Velocidad de salto
export (int) var gravity 	= 1000			# Aceleracion de la gravedad

var velocity = Vector2.ZERO				# Vector velocidad

func _physics_process(delta):				# <- Se ejecuta una vez por cada fotograma

	velocity.x = 0 			# Inicializamos el vector velocidad en [x=0,y=y]

	if Input.is_action_pressed("ui_right"):
		velocity.x += speed # si "ui_right" es presionado [x = speed,y=y]

	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed # si "ui_left" es presionado [x = -speed,y=y]

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():	# si Player esta sobre el suelo
			velocity.y = jump_speed # si "ui_ip" es presionado [x=x,y = jump_speed]

	velocity.y += gravity * delta	# agregamos velocidad de la gravedad por factor de tiempo "delta"

	velocity = move_and_slide(velocity, Vector2.UP) # movemos a player

