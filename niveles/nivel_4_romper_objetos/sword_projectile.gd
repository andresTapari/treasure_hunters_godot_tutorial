extends Area2D

var speed:int 			= 200			#Velocidad del proyecile
var direction:Vector2	= Vector2(1,0)	#Direccion del proyectil
var damage = 1

func _physics_process(delta):		# <- Se ejecuta una vez por cada proceso fisico
	# se mueve sobre el eje x por el factor de velocidad (speed),
	# la constante de tiempo y la direccion
	position += direction.x * transform.x * speed * delta

func _on_sword_projectile_body_entered(body: Node) -> void:
	set_deferred("monitoring",false)
	if body.is_in_group("entity"):
#		$CollisionShape2D.set_deferred("disabled",false)
		body.hit(damage,direction)
		queue_free()
