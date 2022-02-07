extends Area2D

# Nodos:
onready var animatedSprite = get_node("AnimatedSprite")

# Variables
enum item {silver_coin,golden_coin,golden_skull}	# Tipos de item
export (item) var tipo								# tipo de item, editable desde Inspector
var score: int =  0									# variable de puntaje

func _ready():	# <- Se ejecuta cuando el nodo aparece en la escena raiz
	match tipo:										# Evalua el tipo
		item.silver_coin:							# si es una moneda de plata
			animatedSprite.play("silver_coin")		# reproduce animacion de moneda de plata
			score = 5								# puntaje es 5

		item.golden_coin:							# si es una moneda de oro
			animatedSprite.play("golden_coin")		# reproduce animacion de moneda de oro
			score = 10								# puntaje es igual a 10

		item.golden_skull:							# si es una calavera de oro
			animatedSprite.play("golden_skull")		# reproduce animacion de calavera de oro
			score = 20								# puntaje es igual a 20

		_: #default									# por defecto 
			animatedSprite.play("silver_coin")		# reproduce animacion de moneda de plata
			score = 5								# puntaje es igual a 5

func _on_pickable_item_body_entered(body):
	if body.is_in_group("player"):						# si el cuerpo con el que colisiona es player
		body.add_score(score)							# llama a la funcion de player para agregar puntaje
		
		if tipo == item.golden_skull:					# si el item es una calavera
			animatedSprite.play("golden_skull_efect")	# reproduce animacion de efecto de calavera
		else:											# si no es una calavera
			animatedSprite.play("coin_effect")			# reproduce animacion de efecto de moneda

		yield(animatedSprite, "animation_finished")		# espera a que termine la animacion
		queue_free()									# elmina el nodo
