extends KinematicBody2D

# Clases
var SWORD = preload("res://niveles/nivel_4_romper_objetos/sword_projectile.tscn")

# Señales:
signal update_score(_value) #->lvl/CanvasLayer.handle_update_score(_value)

# Nodos:
onready var animatedSprite 	= get_node('AnimatedSprite')
onready var rayCast			= get_node("RayCast2D")		#Nodo RayCast 2D
onready var muzzle			= get_node('Muzzle_rotation/Muzzle')		# Nodo del muzzle
onready var muzzleRotation  = get_node('Muzzle_rotation')

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
var damage_range: Vector2		= Vector2(25,0)					# Rango de daño de player
var has_sword: bool				= true							# Bandera que tiene espada
func _physics_process(delta):
	
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
		if !atck_enable:
			animatedSprite.play("run")
			animatedSprite.flip_h = false
			rayCast.cast_to=Vector2(damage_range.x,damage_range.y)
			muzzleRotation.rotation = 0
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
		if !atck_enable:
			animatedSprite.play("run")
			animatedSprite.flip_h = true
			rayCast.cast_to=Vector2(-damage_range.x,damage_range.y)
			muzzleRotation.rotation = PI
	# Ataque Melee
	if Input.is_action_just_pressed("ui_hit"):
		if !atck_enable:
			atck_enable = true
			if is_on_floor():
				if action_counter > 2:
					action_counter = 0
				animatedSprite.play(hit_animation_floor[action_counter]) 
			else:
				if action_counter > 1:
					action_counter = 0
				animatedSprite.play(hit_animation_air[action_counter]) 
			action_counter += 1
		# Generar Daño:
			var collider = rayCast.get_collider()
			if collider:
				if collider.is_in_group("entity"):
					collider.hit(damage,rayCast.cast_to)
			yield(animatedSprite,"animation_finished")
			atck_enable = false
			
	# Golpe de rango:
	if Input.is_action_just_pressed('ui_throw') and has_sword:
		if !atck_enable:
			has_sword = false
			atck_enable = true
			animatedSprite.play("throw_sword") # <- Ver señal de cambio de frame
			yield(animatedSprite,"animation_finished")
			atck_enable = false

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


func _on_AnimatedSprite_frame_changed() -> void:
	if !atck_enable:
		# Si no esta atacando
		# sale de la función
		return
	if animatedSprite.animation == "throw_sword" and animatedSprite.frame == 1:
		# SPAWN de espada
		var new_projectile = SWORD.instance()
		new_projectile.connect("sword_destroy",self,"handle_sword_destroy")
		new_projectile.direction=rayCast.cast_to.normalized()
		var offset = muzzle.position * rayCast.cast_to.normalized()
		if offset.x < 0:
			new_projectile.get_node('AnimatedSprite').flip_h = true
		new_projectile.position = offset + position
		owner.add_child(new_projectile)
			
func handle_sword_destroy()->void:
	has_sword = true
