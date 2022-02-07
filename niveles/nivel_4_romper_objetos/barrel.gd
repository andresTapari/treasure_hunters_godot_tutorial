extends RigidBody2D

# Clases:
var PARTICULAS = preload('res://niveles/nivel_4_romper_objetos/barrel_particle.tscn')

# Nodos:
onready var animatedSprite	= get_node("AnimatedSprite")
onready var collider		= get_node("CollisionShape2D")

onready var random = RandomNumberGenerator.new()

# Variables:
export var life: int = 3		# Cantidad de vida del barril
export var explosion_force = 350

func _ready():
	pass # Replace with function body.

func hit(_damage: int,_direction) -> void:
	life -= _damage
	self.apply_central_impulse(Vector2(_direction.x*2.5,-25))
	animatedSprite.play("hit")
	if life <= 0:
		collider.disabled = true
		for n in range(4):
			var new_particle = PARTICULAS.instance()
#			get_parent().add_child(new_particle)
			new_particle.get_node("AnimatedSprite").frame = n - 1 
			randomize()
			var x = rand_range(-1,1)
			var y = rand_range(-1,1)
			var impulso = Vector2(x,y).normalized()
			new_particle.apply_impulse(position,impulso*explosion_force)
			add_child(new_particle)
		animatedSprite.visible=false
		$Timer.start()
		
func _on_AnimatedSprite_animation_finished():
	animatedSprite.play("idle")

func _on_Timer_timeout():
	queue_free()
