extends Area2D

# Clases:
var CANON_BALL_PARTICLE = preload("res://niveles/nivel_7_enemigos_rango/canon_bal_particle.tscn")

# Variables:
var speed:int 			= 300			# Velocidad del proyecile
var direction:Vector2	= Vector2.ZERO	# Direccion del proyectil
var damage 				= 5				# Daño que provoca el proyectil
var explosion_force		= 150


func _physics_process(delta):		# <- Se ejecuta una vez por cada proceso fisico
	# se mueve sobre el eje x por el factor de velocidad (speed),
	# la constante de tiempo y la direccion
	position += direction.x * transform.x * speed * delta


func _on_Area2D_body_entered(body):
	call_deferred("set","monitoring",false)
	call_deferred("set","monitoreable",false)
	speed = 0
	if body.is_in_group("player"):
		body.hit(damage,global_position)
	for n in range(3):
			# creamos una instancia de particula cañon
			var new_particle = CANON_BALL_PARTICLE.instance()
			# establecemos el frame de la particula
			new_particle.get_node("AnimatedSprite").frame = n
			# establecemos el frame de la particula
			randomize()
			# generamos un valor flotante entre -1 y 1 para el eje x
			var x = rand_range(-1, 1)
			# generamos un valor flotante entre -1 y 1 para el eje y
			var y = rand_range(-1, 1)
			# creamos un vector impulso con estos valores establecidos
			var impulso = Vector2(x,y)
			# aplicamos el impulso multiplicado por un factor de fuerza
			new_particle.apply_impulse(position + impulso, impulso * explosion_force)
			# la agregamos como hijo del nodo
			call_deferred("add_child",new_particle)
	$AnimatedSprite.play("explosion")
	yield($AnimatedSprite,"animation_finished")
	queue_free()
