extends KinematicBody2D

# Señales:
# Envia una señal hacia el hud con el puntaje.
signal update_score(_value) #->lvl/CanvasLayer.handle_update_score(_value)

# Nodos:
onready var animatedSprite = get_node('AnimatedSprite')

# Variables:
export (int) var speed 		= 250			# Velocidad de movimiento
export (int) var jump_speed = -400			# Velocidad de salto
export (int) var gravity 	= 1000			# Aceleracion de la gravedad

var velocity	= Vector2.ZERO				# Vector velocidad
var score		= 0							# Puntaje del jugador

func _physics_process(delta):
	
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		animatedSprite.play("run")
		animatedSprite.flip_h = false

	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		animatedSprite.play("run")
		animatedSprite.flip_h = true

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_speed

	if velocity == Vector2.ZERO:
		animatedSprite.play("idle")
		
	elif velocity.y < 0:
		animatedSprite.play("jump")
	
	elif velocity.y > 0:
		animatedSprite.play("fall")

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP) # movemos a player

func add_score(_value: int)-> void:
	score += _value							# actualiza el puntaje de player
	emit_signal("update_score",score)		# emite una señal hacia el hud con el puntaje
