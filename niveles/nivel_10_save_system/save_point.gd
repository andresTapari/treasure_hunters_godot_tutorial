extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.modulate = Color(1,1,1,0)

func hit(_value: int, _direction: Vector2) -> void:
	get_tree().paused = true
	$WindowDialog_save.popup_centered()

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		var tween = get_node("Tween")
		tween.interpolate_property($Label, "modulate",
		Color(1,1,1,0), Color(1,1,1,1), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		var tween = get_node("Tween")
		tween.interpolate_property($Label, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
