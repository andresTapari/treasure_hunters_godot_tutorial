extends Node2D

# Variables
export var damage: int = 10

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		pass
#		body.hit(damage)
