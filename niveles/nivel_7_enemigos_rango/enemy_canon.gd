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
onready var timer_queuefree      = get_node("Timer_queuefree")
# Variables:
export var cadence: 		 int = 5		# cadencia de disparo del cañon
export var life: 			 int = 3		# vida del cañon
export var knock_back_force: int = 5		# fuerza de empuje hacia atras.
export var explosion_force:  int = 60		# fuerza de empuje de particulas
export var flipped:			bool = false	# invierte el cañon

func _ready():
	timer_queuefree.connect('timeout',self,'queue_free')
	# si esta invertido
	if flipped:
		# invertimos la direccion del muzzle
		muzzle_origin.scale = Vector2(-1,1)
		# espejamos los prites del cañon
		animatedSpriteCanon.flip_h = true
	# establecemos el tiempo de espera entre disparos como "cadence"
	timer.wait_time = cadence
	# iniciamos le timer
	timer.start()
	

func hit(_damage: int,_direction) -> void:
	if life <= 0:
		timer.stop()
		return
	# si la animacion se esta reproduciendo
	if animatedSpriteCanon._is_playing():
		# salimos de la funcion
		return
	# a la variable vida le descuenta el daño.
	life -= _damage
	# amplicamos un impulso en direccion del golpe, con la fuerza definida en knock_back_force
	self.apply_central_impulse(Vector2(_direction.x * knock_back_force, -knock_back_force))
	# se reproduce la animación hit
	animatedSpriteCanon.play("hit")
	# aplicamos un impulso de knock_back
	yield(animatedSpriteCanon,"animation_finished")
	
	if is_instance_valid(animatedSpriteCanon):
		# reproducimos la animacion idle
		animatedSpriteCanon.play("idle")
		# detenemos la animacion
		animatedSpriteCanon.stop()
	
func _on_Timer_timeout():
	# reproducimos animacion de fire
	animatedSpriteCanon.play("fire")
	# esperamos a que la animacion termine
	yield(animatedSpriteCanon,"animation_finished")
	# reproducimos la animacion idle
	animatedSpriteCanon.play("idle")
	# detenemos animacion
	animatedSpriteCanon.stop()



func _on_AnimatedSprite_cannon_frame_changed():
	# si la animacion es "fire"
	if animatedSpriteCanon.animation == "fire":
		# y si el frame es 3:
		if animatedSpriteCanon.frame == 3: 
			# reproducimos animacion "fire"
			animatedSpriteMuzzle.play("fire")
			# creamos una instancia CANON_BAL
			var canon_bal = CANON_BAL.instance()
			# si esta invertido el cañon
			if flipped:
				# asignamos la direccion x+
				canon_bal.direction=Vector2(1,0)
				# asignamos la posicion en el mundo
				canon_bal.position = self.position - muzzle.position
			# si no esta invertido el cañon
			else:
				# asignamos la direccion x-
				canon_bal.direction=Vector2(-1,0)
				# asignamos la posicion en el mundo 
				canon_bal.position = self.position + muzzle.position
			# agregamos al nodo padre del cañon, la instancia de la bala de cañon
			owner.add_child(canon_bal)
			# esperamos que la animacion del muzzle termine 
			yield(animatedSpriteMuzzle,"animation_finished")
			
			if is_instance_valid(animatedSpriteMuzzle):
				# establecemos la animacon "idle en el muzzle"
				animatedSpriteMuzzle.play("idle")
				# detenemos la animacion
				animatedSpriteMuzzle.stop()

	# si la animacion es HIT, y la vida igual o menor a cero
	if animatedSpriteCanon.animation == "hit" and life <=0:
		# y si el frame es 1
		if animatedSpriteCanon.frame == 1: 
			# hacemos invisible el sprite
			animatedSpriteCanon.visible = false
			# repeimos 3 veces:
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
				var y = rand_range(-1, -1)
				# creamos un vector impulso con estos valores establecidos
				var impulso = Vector2(x,y)
				# aplicamos el impulso multiplicado por un factor de fuerza
				new_particle.apply_impulse(position, impulso * explosion_force)
		timer_queuefree.start()


