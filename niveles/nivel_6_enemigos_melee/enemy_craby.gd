extends RigidBody2D


# Nodos:
onready var animatedSprite = get_node('AnimatedSprite')

# Constante:
enum state {idle,patrol,atack}

# Variables:
export var life 		= 10
export var force_factor = 45
var current_state = state.idle
var been_hited: bool = false



func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	pass
#	match current_state:
#		state.idle:
#			animatedSprite.play("idle")
#		_:#default
#			pass

func hit(_damage: int,_direction) -> void:
	# A la variable vida le descuenta el daño.
	life -= _damage
	# se carga un impulso en direccón del golpe
	self.apply_central_impulse(Vector2(_direction.x*force_factor,-35))
	# reproducimos animacion de daño
	var current_animation = animatedSprite.animation
	animatedSprite.play("hit")
	if _direction.x < 0:
		animatedSprite.flip_h = true
	else:
		animatedSprite.flip_h = false
	yield(animatedSprite,'animation_finished')
	animatedSprite.play("idle")
