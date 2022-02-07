extends CanvasLayer

# Nodos:
onready var label_coin: Label = get_node("Label")

func handle_update_score(_value: int) -> void:
	label_coin.text = String(_value)	#Convertimos a string y lo asignamos a label
