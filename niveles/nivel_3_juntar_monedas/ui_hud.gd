extends CanvasLayer

# Nodos:
onready var label_coin: Label = get_node("Label")

func handle_update_score(_value: int) -> void:
	#Convertimos a string y lo asignamos a label
	label_coin.text = String(_value)
