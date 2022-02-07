extends KinematicBody2D

# Nodos:
onready var animatedSprite = get_node('AnimatedSprite')		#cargamos nodo AnimatedSprite en variable

# Variables:
export (int) var speed 		= 250			# Velocidad de movimiento
export (int) var jump_speed = -400			# Velocidad de salto
export (int) var gravity 	= 1000			# Aceleracion de la gravedad

var velocity = Vector2.ZERO				# Vector velocidad

func _physics_process(delta):
	
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):		# si player se mueve a la derecha
		velocity.x += speed
		animatedSprite.play("run")				# reproduce animacion correr
		animatedSprite.flip_h = false			# voltear sprite horizontalmente hacia la derecha

	if Input.is_action_pressed("ui_left"):		# si player se mueve hacia la izquierda
		velocity.x -= speed
		animatedSprite.play("run")				# reproduce animacion correr
		animatedSprite.flip_h = true			# voltea sprite horizontalmente hacia la izquierda

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_speed

	if velocity == Vector2.ZERO:		# si player esta quieto:
		animatedSprite.play("idle")		# reproduce animacion estar
		
	elif velocity.y < 0:				# si player se esta saltando
		animatedSprite.play("jump")		# reproduce animacion saltar
	
	elif velocity.y > 0:				# si player esta cayendo
		animatedSprite.play("fall")		# reproduce animacion caer

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP) # movemos a player

