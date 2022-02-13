extends Node2D

# Variables
export var damage: int = 2

func _on_Area2D_body_entered(body):
	# Se ejecutara cuando una entidad o el jugador entre en su zona de colision
	if body.is_in_group("player"):
		# Si el cuerpo de colision es del grupo player
		# llama a la funcion hit de player y le pasa su daño como argumento
		# y su posicion
		body.hit(damage,global_position)
