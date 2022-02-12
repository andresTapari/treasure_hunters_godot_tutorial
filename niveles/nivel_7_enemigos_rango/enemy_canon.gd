extends RigidBody2D


# Clases:
var CANON_BAL = preload("res://niveles/nivel_7_enemigos_rango/canon_bal.tscn")

# Nodos:
onready var animatedSpriteCanon  = get_node("AnimatedSprite_cannon")
onready var animatedSpriteMuzzle = get_node("muzzle/AnimatedSprite_muzzle")
onready var timer                = get_node("Timer")

# Variables:
export var cadence: int = 5		# cadencia de disparo del cañon

func _ready():
	timer.start()

func _on_Timer_timeout():
	# cuando el timer se agote:
	var canon_bal = CANON_BAL.instance()
	# agregamos el nodo hijo
	owner.add_child(canon_bal)
