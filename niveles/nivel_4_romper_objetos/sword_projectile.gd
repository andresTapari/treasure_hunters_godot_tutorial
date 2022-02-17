extends Area2D

# Señales:
signal sword_destroy # ->player.handle_sword_destroy

# Variables:
var speed:int 			= 200			#Velocidad del proyecile
var direction:Vector2	= Vector2(1,0)	#Direccion del proyectil
var damage = 1

func _physics_process(delta):		# <- Se ejecuta una vez por cada proceso fisico
	# se mueve sobre el eje x por el factor de velocidad (speed),
	# la constante de tiempo y la direccion
	position += direction.x * transform.x * speed * delta

func _on_sword_projectile_body_entered(body: Node) -> void:
	call_deferred("set","monitoring",false)
	if body.is_in_group("entity") or body.is_in_group("interruptor"):
		body.hit(damage,direction)
		emit_signal("sword_destroy")
		queue_free()
	else:
		speed = 0
		$AnimatedSprite.play("embedded")
		yield($AnimatedSprite,"animation_finished")
		emit_signal("sword_destroy")
		queue_free()


func _on_sword_projectile_area_entered(area: Area2D) -> void:
	if area.is_in_group("interruptor"):
		area.hit(0,Vector2.ZERO)
		emit_signal("sword_destroy")
		queue_free()
