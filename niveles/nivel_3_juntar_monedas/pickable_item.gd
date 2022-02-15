extends Area2D

# Nodos:
onready var animatedSprite = get_node("AnimatedSprite")

# Variables
enum item {silver_coin,golden_coin,golden_skull}	# Tipos de item
export (item) var tipo								# tipo de item, editable desde Inspector
var score: int =  0									# variable de puntaje
var id:	String = ""

func _ready():	# <- Se ejecuta cuando el nodo aparece en la escena raiz
	id = owner.id + "_" + name
	print_debug(id)
	match tipo:	# <- Evalua el tipo
		item.silver_coin:
			# si es una moneda de plata
			# reproduce animacion de moneda de plata
			animatedSprite.play("silver_coin")
			# puntaje es 5
			score = 5
		item.golden_coin:
			# si es una moneda de oro
			# reproduce animacion de moneda de oro
			animatedSprite.play("golden_coin")
			# puntaje es igual a 10
			score = 10

		item.golden_skull:
			# si es una calavera de oro
			# reproduce animacion de calavera de oro
			animatedSprite.play("golden_skull")
			# No agrega puntaje
			score = 0
 
		_: #default
			# reproduce animacion de moneda de plata
			animatedSprite.play("silver_coin")
			# puntaje es igual a 5
			score = 5

func _on_pickable_item_body_entered(body):
	var _lives = 0
	# si el cuerpo con el que colisiona es player
	if body.is_in_group("player"):
		if tipo == item.golden_skull:
			# Agrega una vida
			_lives += 1
			# si el item es una calavera
			# reproduce animacion de efecto de calavera
			animatedSprite.play("golden_skull_efect")
		else:
			# si no es una calavera
			# reproduce animacion de efecto de moneda
			animatedSprite.play("coin_effect")
		# llama a la funcion de player para agregar puntaje
		body.add_score(score,_lives)
		# espera a que termine la animacion
		yield(animatedSprite, "animation_finished")
		# llamamos a la funcion add_to_picked_item_list para agregar
		# el item a la lista de items conseguidos (de esta forma evitamos que
		# al volver a pasar por el nivel re aparezcan todos los items)
		GLOBAL.add_to_picked_item_list(id)
		# elmina el nodo
		queue_free()
