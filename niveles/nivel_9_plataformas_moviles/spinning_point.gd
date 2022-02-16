extends Area2D

func _on_Spinning_point_body_entered(body: Node) -> void:
	# Si el cuerpo es parte del grupo platform
	if body.is_in_group("platform"):
		# llama a la funcion spin y le pasa un giro de 360º
		body.spin(360);
