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
		# animacion de golpe:
		# Animacion:
		if !atck_enable:
			# si no esta atacando
			# entra en modo ataque
			atck_enable = true
			if is_on_floor():
			# si esta en el piso
				if action_counter > 2:
					# y si el indx de accion es > a 2
					# indx de accion es 0
					action_counter = 0
				# reproduce la animacion  del indx
				animatedSprite.play(hit_animation_floor[action_counter]) 
			else:
			# si esta en el aire
				if action_counter > 1:
					#y si el contador de accion es > a 1
					# indx de accion es 0
					action_counter = 0
					# reproduce la animacion del indx
				animatedSprite.play(hit_animation_air[action_counter]) 
			# incrementa el index
			action_counter += 1
		# Generar Daño:
			# inspecciona las colisiones del raycast
			var collider = rayCast.get_collider()
			if collider:
				# si el collider es distinto de null
				if collider.is_in_group("entity"):
					# y si el collider esta en el grupo entity
					# llama a la función hit del collider
					collider.hit(damage,rayCast.cast_to)
					# espera a que termine la animacion de golpe
			yield(animatedSprite,"animation_finished")
			# sale en modo combate
			atck_enable = false
			
	# Golpe de rango:
	if Input.is_action_just_pressed('ui_throw') and has_sword:
		if !atck_enable:
			# ponemos la variable en falso para evitar que vuelva arrojar la 
			# espada mientras la instancia anterior este en el aire.
			has_sword = false
			# si no esta atacando
			# entra en modo ataque
			atck_enable = true
			animatedSprite.play("throw_sword") # <- Ver señal de cambio de frame
			# Espera a que la animacion termine
			yield(animatedSprite,"animation_finished")
			# sale del modo combate
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
	# evaluamos si la animacion es arrojar espada y si el frame es el 1
	if animatedSprite.animation == "throw_sword" and animatedSprite.frame == 1:
		# SPAWN de espada
		# Creamos instancia de la clase SWORD
		var new_projectile = SWORD.instance()
		# Conectamos la señal de espada destruida con la funcion handle_sword_destroy
		new_projectile.connect("sword_destroy",self,"handle_sword_destroy")
		# Establecemos la direccion del proyectile como la de la direccion del raycast
		new_projectile.direction=rayCast.cast_to.normalized()
		# determinamos el offset de la posicion de spawn de la espada
		var offset = muzzle.position * rayCast.cast_to.normalized()
		if offset.x < 0:
			#si esta mirando en sentido contrario, invertimos la animacion
			new_projectile.get_node('AnimatedSprite').flip_h = true
		# a la instancia agregamos la posicion y el offset
		new_projectile.position = offset + position
		# agregamos la instancia al padre del nodo player.
		owner.add_child(new_projectile)
			
func handle_sword_destroy()->void:
	# volvemos a poner en true la espada para poder volver a lanzarla
	has_sword = true
