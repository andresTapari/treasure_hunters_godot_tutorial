extends KinematicBody2D

# Clases
var SWORD = preload("res://niveles/nivel_4_romper_objetos/sword_projectile.tscn")

# Señales:
signal update_score(_value) #->lvl/CanvasLayer.handle_update_score(_value)
# Agregamos otra señal para actualizar el total de vida
signal update_health(_total,_actual) #->lvl/CanvasLayer.handle_update_health(_total,_actual)

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
export (int) var total_life = 10			# Total de vida del jugador
export (int) var life		= 10			# Cantidad de vida del jugador
export (int) var knokback_f = 150			# Fuerza de empuje hacia atras cuando el jugador percibe daño

var velocity:Vector2			= Vector2.ZERO					# Vector velocidad
var score:int					= 0								# Puntaje del jugador
var action_counter:int			= 0								# Contador de animacion de golpe
var hit_animation_floor:Array	= ["atack_1","atack_2","atack_3"] #Aniaciones de ataque
var hit_animation_air:Array		= ["air_atack_1","air_atack_2"]	# Animaciones de ataque en el aire
var atck_enable: bool			= false							# Vandera que player esta atacando
var damage_range: Vector2		= Vector2(25,0)					# Rango de daño de player
var has_sword: bool				= true							# Bandera que tiene espada
var move_enable: bool			= true							# Bandera para mover jugador

func _ready() -> void:
	# cargamos el puntaje de global:
	score = GLOBAL.score
	life = GLOBAL.health
	total_life = GLOBAL.total_health

	# actualizamos la barra de vida al comienzo del nivel y el oro
	emit_signal('update_health',total_life,life)
	emit_signal('update_score',score)

func _physics_process(delta):
	if move_enable:
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
				# si esta en el aire
					if action_counter > 1:
						action_counter = 0
					animatedSprite.play(hit_animation_air[action_counter]) 
				action_counter += 1
			# Generar Daño:
				rayCast.force_update_transform()
				var collider = rayCast.get_collider()
				print_debug(collider)
				if collider:
					if collider.is_in_group("entity"):
						if collider is RigidBody2D:
							collider.hit(damage,rayCast.cast_to.normalized())
						elif collider is Area2D:
							collider.get_parent().hit(damage,rayCast.cast_to.normalized())
					if collider.is_in_group("door"):
						collider.hit(damage,rayCast.cast_to.normalized())
				yield(animatedSprite,"animation_finished")
				# sale en modo combate
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
		
		elif velocity.y < 0 and move_enable:
			animatedSprite.play("jump")
		
		elif velocity.y > 0:
			animatedSprite.play("fall")
	
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP) 

func add_score(_value: int)-> void:
	score += _value
	GLOBAL.score += _value
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
			
func handle_sword_destroy() -> void:
	# volvemos a poner en true la espada para poder volver a lanzarla
	has_sword = true

func hit(_damage,_origin) -> void:
	# determinamos la direccion donde proviene el daño
	var dir: Vector2= global_position.direction_to(_origin)
	# evaluamos si esta a la izquierda:
	if dir.x < 0:
		# la velocidad en x resultante sera la fuerza de empuje dividido 2
		velocity.x = knokback_f/2
	else:
		# la velocidad en x resultante sera la fuerza negativa de empuje dividido 2
		velocity.x = -knokback_f/2
	# la velocidad en y sera:
	velocity.y = -knokback_f
	# se ejecuta cada vez que el personaje percibe daño
	# Se resta la vida por el daño que percibe el personaje
	life -= _damage 
	# cargamos en la variable global la vida actual del personaje
	GLOBAL.health = life
	# se emite una señal para actualizar la barra de vida del personaje
	emit_signal('update_health',total_life,life)
	# colocamos la bandera de ataque en alto para forzar la animacion de daño
	atck_enable=true
	# evitamos que se siga moviendo
	move_enable = false
	# si ya no le queda vida
	if life <= 0:
		# desactivamos la caja de colision para que deje de percibir daño 
		# o juntar items y se caiga por los limites de la pantalla
		$CollisionShape2D.set_deferred("disabled",true)
		# reproducimos la animación die
		animatedSprite.play("die")
		# Esperamos a que la animacion termine
		yield(animatedSprite,"animation_finished")
		# detenemos animación
		animatedSprite.stop()
		# salimos de la función
		return
	# reproducimos animación de daño
	animatedSprite.play("hurt")
	# esperamos que la animacion termine
	yield(animatedSprite,"animation_finished")
	# desactivamos las banderas
	atck_enable=false
	move_enable = true

func heal(_value) -> void:
	life += _value
	GLOBAL.health = life
	if life > total_life:
		life = total_life
	emit_signal('update_health',total_life,life)

func _on_VisibilityNotifier2D_screen_exited() -> void:
	#warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().reload_current_scene()
