extends Area2D

# Variables:
var speed:int 			= 200			# Velocidad del proyecile
var direction:Vector2	= Vector2.ZERO	# Direccion del proyectil
var damage 				= 5				# Daño que provoca el proyectil

func _physics_process(delta):		# <- Se ejecuta una vez por cada proceso fisico
	# se mueve sobre el eje x por el factor de velocidad (speed),
	# la constante de tiempo y la direccion
	position += direction.x * transform.x * speed * delta


func _on_Area2D_body_entered(body):
	speed = 0
	$AnimatedSprite.play("explosion")
	yield($AnimatedSprite,"animation_finished")
	queue_free()
