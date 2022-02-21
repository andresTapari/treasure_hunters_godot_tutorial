extends Area2D

signal hide_hud(_value) # lvl->handle_hide_hud

func _ready() -> void:
	$Label.modulate = Color(1,1,1,0)

func hit(_value: int, _direction: Vector2) -> void:
#	GLOBAL.image_buffer = $Camera2D.get_viewport().get_texture().get_data()

	GLOBAL.image_buffer = get_viewport().get_texture().get_data()
	GLOBAL.image_buffer.flip_y()
#	GLOBAL.image_buffer = GLOBAL.image_buffer.flip_y()

	emit_signal("hide_hud",true)
	$WindowDialog_save.popup_centered()
	get_tree().paused = true
	yield($WindowDialog_save,"hide")
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
