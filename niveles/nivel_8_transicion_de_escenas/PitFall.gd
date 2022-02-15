extends Area2D

func _on_PitFall_body_entered(body: Node) -> void:
	# Si body esta en el grupo player
	if body.is_in_group("player") or body.is_in_group("entity"):
		# le descuenta 999 de vida para muerte instantanea
		body.hit(999)
