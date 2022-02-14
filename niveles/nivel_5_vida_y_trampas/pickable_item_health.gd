extends Area2D

# Constantes:
enum type {small_potion,medium_potion ,big_potion}

# Nodos:
onready var animatedSprite = get_node('AnimatedSprite')

# Variables:
export (type) var tipo = type.small_potion			# Exporamos variable para elegir que tipo de posion es

var small_potion_health		= 2						# Cantidad de vida que cura posion pequeña
var medium_potion_health	= 5						# Cantidad de vida que cura posion mediana
var big_potion_health		= 10 					# Cantidad de vida que curar posion grande
var health_value = small_potion_health				# Cantidad de vida que se pasa como argumento
var id:	String = ""

func _ready() -> void:
	id = owner.id + "_" + name
	#Cuando el nodo comienza
	match tipo:
		# si es del tipo posion pequeña
		type.small_potion:
			# asigna animacion de posion pequeña
			animatedSprite.play("small_potion")
			# carga el valor de a posion pequeña
			health_value = small_potion_health
		type.medium_potion:
			# asigna animacion de posion mediana
			animatedSprite.play("medium_potion")
			# carga el valor de la de posion mediana
			health_value = medium_potion_health
		type.big_potion:
			# asigna animacion de posion grande
			animatedSprite.play("big_potion")
			# Carga el valor de la posion grande
			health_value = big_potion_health



func _on_pickable_item_health_body_entered(body: Node) -> void:
		# Esta funcion se ejcuta si una entidad toca la posion
	if body.is_in_group("player"):
		# Desactivamos la forma de colision para que no la junte varias veces 
		# mientras la misma desaparece
		$CollisionShape2D.set_deferred("disabled",true)
		# si la entidad es player
		if body.total_life == body.life:
			# si el player tiene toda su viada, sale de la funcion
			return
		# llama a la funcion curar de player, y le pasa el valor de curar como argumento
		body.heal(health_value)
		# reproduce animacion de consumir posion
		animatedSprite.play("potion_effect")
		# Agregamos a la lista de objetos conseguidos
		GLOBAL.add_to_picked_item_list(id)
		# Espera a que la animacion termine
		yield(animatedSprite,"animation_finished")
		# elimina el nodo posion
		queue_free()

