extends Node2D

# Variables
export var damage: int = 2

func _on_Area2D_body_entered(body):
	# Se ejecutara cuando una entidad o el jugador entre en su zona de colision
	if body.is_in_group("player"):
		# Si el cuerpo de colision es del grupo player
		# llama a la funcion hit de player y le pasa su daño como argumento
		body.hit(damage)
		# Cargamos el nodo Tween en una variable
		var tween = get_node("Tween")
		# cargamos parametro al nodo Tween
		tween.interpolate_property($StaticBody2D/CollisionShape2D.get_shape(),
		 "extents",Vector2(10,10),Vector2(40,40),0.05,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		# Iniciamos en nodo Tween, este hace que la caja de colision de statick body
		# aumente su tamaño, empujando al jugador, logrando generar el efecto
		# de knock back del mismo al recibir daño.
		tween.start()
		# Esperamos que tween termine
		yield(tween,'tween_all_completed')
		# Reestablecemos la dimension original
		$StaticBody2D/CollisionShape2D.get_shape().extents = Vector2(10,10)
