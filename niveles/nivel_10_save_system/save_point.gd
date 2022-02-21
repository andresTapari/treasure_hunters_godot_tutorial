extends Area2D

signal hide_hud(_value) # lvl->handle_hide_hud

func _ready() -> void:
	$Label.modulate = Color(1,1,1,0)

func hit(_value: int, _direction: Vector2) -> void:
	# Sacamos captura de la pantalla de juego
	GLOBAL.image_buffer = get_viewport().get_texture().get_data()
	# Rotamos la imagen
	GLOBAL.image_buffer.flip_y()
	# Emitimos una señal para esconder el HUD
	emit_signal("hide_hud",true)
	# Llamamos a la función popup, que hace aparecer una ventana de dialgo
	$WindowDialog_save.popup_centered()
	# Pausamos la escena
	get_tree().paused = true
	# Esperamos a que la ventana de dialogo se oculte
	yield($WindowDialog_save,"hide")
	# Reaparecemos el HUD
	emit_signal("hide_hud",false)

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var tween = get_node("Tween")
		tween.interpolate_property($Label, "modulate",
		Color(1,1,1,0), Color(1,1,1,1), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

func _on_Area2D_body_exited(body: Node) -> void:
#	emit_signal("hide_hud",false)
	if body.is_in_group("player"):
		var tween = get_node("Tween")
		tween.interpolate_property($Label, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
