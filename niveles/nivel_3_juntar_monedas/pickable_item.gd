extends Area2D

# Nodos:
onready var animatedSprite = get_node("AnimatedSprite")

# Variables
enum item {silver_coin,golden_coin,golden_skull}	# Tipos de item
export (item) var tipo								# tipo de item, editable desde Inspector
var score: int =  0									# variable de puntaje

func _ready():	# <- Se ejecuta cuando el nodo aparece en la escena raiz
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
			# puntaje es igual a 20
			score = 20

		_: #default
			# reproduce animacion de moneda de plata
			animatedSprite.play("silver_coin")
			# puntaje es igual a 5
			score = 5

func _on_pickable_item_body_entered(body):
	# si el cuerpo con el que colisiona es player
	if body.is_in_group("player"):
		# llama a la funcion de player para agregar puntaje
		body.add_score(score)
		if tipo == item.golden_skull:
			# si el item es una calavera
			# reproduce animacion de efecto de calavera
			animatedSprite.play("golden_skull_efect")
		else:
			# si no es una calavera
			# reproduce animacion de efecto de moneda
			animatedSprite.play("coin_effect")

		# espera a que termine la animacion
		yield(animatedSprite, "animation_finished")
		# elmina el nodo
		queue_free()
