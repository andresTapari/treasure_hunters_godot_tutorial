extends RigidBody2D

# Clases:
var PARTICULAS = preload('res://niveles/nivel_4_romper_objetos/breakable_particle.tscn')

# Constantes:
enum tipo {barrel, box}

# Nodos:
onready var animatedSprite	= get_node("AnimatedSprite")			# Nodo de animacion
onready var collider_barrel	= get_node("CollisionShape2D_barrel")	# Nodo del collider del barril
onready var collider_box	= get_node("CollisionShape2D_box")		# Nodo del collider de la caja

# Variables:
export var life: int = 3						# Cantidad de vida del barril
export var explosion_force = 350				# Fuerza con la que vuelan las particulas al romperse
export (tipo) var type = tipo.barrel			# Tipo de item rompible (caja o barril)
var particle_animation: String = ""				# Variable donde se aloja la animacion
var collider									# Variable del collider

func _ready():
	if type == tipo.box:
		# Si el tipo de item es una caja, carga el recurso de animacion de la caja al animatedSprite
		animatedSprite.frames = preload("res://assets/animations/breakable_box.tres") 
		# establece que la animación de la particula es de la caja
		particle_animation = "particle_box"
		# y que el collider a usar es el que la caja.
		collider = collider_box
	
	elif type == tipo.barrel:
		# en caso contrario, establece los mismos parametros para el barril
		animatedSprite.frames = preload("res://assets/animations/breakable_barrel.tres")
		particle_animation = "particle_barrel"
		collider = collider_barrel
	# habilita la forma de collider que interactua con el entorno
	collider.set_deferred("disabled",false)

func hit(_damage: int,_direction) -> void:
	# a la variable vida le descuenta el daño.
	life -= _damage
	# se carga un impulso en direccón del golpe
	self.apply_central_impulse(Vector2(_direction.x*3.5,-35))
	# se reproduce la animación hit
	animatedSprite.play("hit")
	if life <= 0:
		# si la vida llega a cero 
		collider.call_deferred("set","disabled",true)
		# en un bucle de 4 iteraciones
		for n in range(4):
			# creamos una instancias de las partes del objeto
			var new_particle = PARTICULAS.instance()
			# la agregamos como hijo del nodo
			call_deferred("add_child",new_particle)
			# establecemos que animacion es (caja o barril)
			new_particle.get_node("AnimatedSprite").animation = particle_animation
			# establecemos el frame
			new_particle.get_node("AnimatedSprite").frame = n - 1 
			if type == tipo.barrel:
				# si es una barril, usamos el barril como forma de colision
				# call_deferred("set","disabled",false) es igual collider.disabled = false 
				# solo que lo hace durante el tiempo de inactividad, evitando errores. 
				new_particle.get_node("CollisionShape2D_barrel").call_deferred("set","disabled",false)
			else:
				# si es una caja, usamos la caja como forma de colision
				new_particle.get_node("CollisionShape2D_box").call_deferred("set","disabled",false)
			# actualizamos la semilla aleatoria
			randomize()
			# generamos un valor flotante entre -1 y 1 para el eje x
			var x = rand_range(-1,1)
			# generamos un valor flotante entre -1 y 1 para el eje y
			var y = rand_range(-1,1)
			# creamos un vector impulso con estos valores establecidos
			var impulso = Vector2(x,y)
			# aplicamos el impulso multiplicado por un factor de fuerza
			new_particle.apply_impulse(position,impulso*explosion_force)
		# ponemos invisible el sprite del objeto
		animatedSprite.visible = false
		# comenzamos el timer
		$Timer.start()

func _on_AnimatedSprite_animation_finished():
	# cuando una animación terminar, reproduce idle
	animatedSprite.play("idle")
	# detiene el bucle de animacion.
	animatedSprite.stop()

func _on_Timer_timeout():
	# cuando el timer termina elimina el nodo principal y todos sus hijos
	queue_free()
