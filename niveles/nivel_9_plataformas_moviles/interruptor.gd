extends Area2D

export var target_path: NodePath
var target

func _ready() -> void:
	if !target_path.is_empty():
		target = get_node(target_path)
		update_animation() 

func hit(_damage,_direction) -> void:
	target.set_enable(!target.enable)
	update_animation() 

func update_animation() -> void:
	if target.enable:
		$AnimatedSprite.play("spinning")
	else:
		$AnimatedSprite.play("idle")
