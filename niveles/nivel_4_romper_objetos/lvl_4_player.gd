extends KinematicBody2D

# Señales:
signal update_score(_value) #->lvl/CanvasLayer.handle_update_score(_value)

# Nodos:
onready var animatedSprite 	= get_node('AnimatedSprite')
onready var rayCast			= get_node("RayCast2D")		#Nodo RayCast 2D

# Variables:
export (int) var speed 		= 250			# Velocidad de movimiento
export (int) var jump_speed = -400			# Velocidad de salto
export (int) var gravity 	= 1000			# Aceleracion de la gravedad
export (int) var damage		= 1				# Daño que provoca el jugador

var velocity:Vector2			= Vector2.ZERO					# Vector velocidad
var score:int					= 0								# Puntaje del jugador
var action_counter:int			= 0								# Contador de animacion de golpe
var hit_animation_floor:Array	= ["atack_1","atack_2","atack_3"] #Aniaciones de ataque
var hit_animation_air:Array		= ["air_atack_1","air_atack_2"]	# Animaciones de ataque en el aire
var atck_enable: bool			= false							# Vandera que player esta atacando
var damage_range: Vector2	= Vector2(25,0)

func _physics_process(delta):
	
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		if !atck_enable:
			animatedSprite.play("run")
			animatedSprite.flip_h = false
			rayCast.cast_to=Vector2(damage_range.x,damage_range.y)

	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		if !atck_enable:
			animatedSprite.play("run")
			animatedSprite.flip_h = true
			rayCast.cast_to=Vector2(-damage_range.x,damage_range.y)

	if Input.is_action_just_pressed("ui_hit"): 	# animacion de golpe:
		# Animacion:
		if !atck_enable:						# si no esta atacando
			atck_enable = true					# entra en modo ataque
			if is_on_floor():					# si esta en el piso
				if action_counter > 2: 			# y si el indx de accion es > a 2
					action_counter = 0			# indx de accion es 0
				animatedSprite.play(hit_animation_floor[action_counter]) # reproduce la animacion  del indx
			else:								# si esta en el aire
				if action_counter > 1:			#y si el contador de accion es > a 1
					action_counter = 0			# indx de accion es 0
				animatedSprite.play(hit_animation_air[action_counter]) # reproduce la animacion del indx
			action_counter += 1					# incrementa el index
		# Generar Daño:
			var collider = rayCast.get_collider()
			print(collider)
			if collider:
				if collider.is_in_group("entity"):
					collider.hit(damage,rayCast.cast_to)
			yield(animatedSprite,"animation_finished")	# espera a que termine la animacion de golpe
			atck_enable = false					# sale en modo combate

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_speed
	
	if !atck_enable:
		if velocity == Vector2.ZERO:
			animatedSprite.play("idle")
			
		elif velocity.y < 0:
			animatedSprite.play("jump")
		
		elif velocity.y > 0:
			animatedSprite.play("fall")



	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP) 

func add_score(_value: int)-> void:
	score += _value
	emit_signal("update_score",score)
