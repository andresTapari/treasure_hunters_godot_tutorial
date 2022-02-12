extends RigidBody2D


# Clases:
var CANON_BAL      = preload("res://niveles/nivel_7_enemigos_rango/canon_bal.tscn")
var CANON_PARTICLE = preload("res://niveles/nivel_7_enemigos_rango/enemy_canon_particle.tscn") 

# Nodos:
onready var animatedSpriteCanon  = get_node("AnimatedSprite_cannon")
onready var animatedSpriteMuzzle = get_node("Position2D/muzzle/AnimatedSprite_muzzle")
onready var muzzle_origin		 = get_node("Position2D")
onready var muzzle				 = get_node("Position2D/muzzle")
onready var timer                = get_node("Timer")

# Variables:
export var cadence: 		 int = 5		# cadencia de disparo del cañon
export var life: 			 int = 3		# vida del cañon
export var knock_back_force: int = 5		# fuerza de empuje hacia atras.
export var explosion_force:  int = 5		# fuerza de empuje de particulas
export var flipped:			bool = false	# invierte el cañon

func _ready():
	if flipped:
		muzzle_origin.scale = Vector2(-1,1)
		animatedSpriteCanon.flip_h = true
	apply_scale(Vector2(1,1))
	timer.start()

func hit(_damage: int,_direction) -> void:
	if animatedSpriteCanon._is_playing():
		return
	# a la variable vida le descuenta el daño.
	life -= _damage
	if life <=0:
		timer.stop()
		animatedSpriteCanon.visible = false
		# Repetimos lo siguiente 3 veces
		for n in range(3):
			# creamos una instancia de particula cañon
			var new_particle = CANON_PARTICLE.instance()
			# la agregamos como hijo del nodo
			call_deferred("add_child",new_particle)
			# establecemos el frame de la particula
			new_particle.get_node("AnimatedSprite").frame = n
			# establecemos el frame de la particula
			new_particle.get_node("AnimatedSprite").flip_h = flipped
			# actualizamos la semilla aleatoria
			randomize()
			# generamos un valor flotante entre -1 y 1 para el eje x
			var x = rand_range(-1, 1)
			# generamos un valor flotante entre -1 y 1 para el eje y
			var y = rand_range(-1, 1)
			# creamos un vector impulso con estos valores establecidos
			var impulso = Vector2(x,y)
			# aplicamos el impulso multiplicado por un factor de fuerza
			new_particle.apply_impulse(position, impulso * explosion_force)
		# creamos un timer
		yield(get_tree().create_timer(1), "timeout")	
		# eliminamos el nodo
		queue_free()
	# amplicamos un impulso en direccion del golpe, con la fuerza definida en knock_back_force
	self.apply_central_impulse(Vector2(_direction.x * knock_back_force, -knock_back_force))
	# se reproduce la animación hit
	animatedSpriteCanon.play("hit")
	# aplicamos un impulso de knock_back
	yield(animatedSpriteCanon,"animation_finished")
	# reproducimos la animacion idle
	animatedSpriteCanon.play("idle")
	# detenemos la animacion
	animatedSpriteCanon.stop()
	


func _on_Timer_timeout():
	animatedSpriteCanon.play("fire")
	yield(animatedSpriteCanon,"animation_finished")
	# reproducimos la animacion idle
	animatedSpriteCanon.play("idle")
	animatedSpriteCanon.stop()

	
	# funcon de disparo del cañon
	yield(animatedSpriteCanon,"animation_finished")
	# reproducimos la animacion idle
	animatedSpriteCanon.play("idle")
	pass


func _on_AnimatedSprite_cannon_frame_changed():
	if animatedSpriteCanon.animation != "fire":
		return
	if animatedSpriteCanon.frame == 3: 
		animatedSpriteMuzzle.play("fire")
		var canon_bal = CANON_BAL.instance()
		if flipped:
			canon_bal.direction=Vector2(1,0)
			canon_bal.position = self.position - muzzle.position
		else:
			canon_bal.direction=Vector2(-1,0)
			canon_bal.position = self.position + muzzle.position
		owner.add_child(canon_bal)
		yield(animatedSpriteMuzzle,"animation_finished")
		animatedSpriteMuzzle.play("idle")
