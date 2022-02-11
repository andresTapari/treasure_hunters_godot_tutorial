extends Node2D

# Nodos: 
onready var animatedSprite = get_node('AnimatedSprite')

func _ready() -> void:
	pass
#	animatedSprite.visible = false

func set_dialog(_option: String) -> void:
	animatedSprite.visible = true
	match _option:
		"Dead_In":
			animatedSprite.play("dead_in")
		"Exclamation_In":
			animatedSprite.play("exclamation_in")
		"Interrogation_In":
			animatedSprite.play("interrogation_in")
	yield(animatedSprite,'animation_finished')
	animatedSprite.stop()

