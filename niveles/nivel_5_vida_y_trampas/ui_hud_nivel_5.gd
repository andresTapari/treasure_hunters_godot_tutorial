extends CanvasLayer

# Nodos:
onready var label_coin: Label = get_node("Node2D/Label")
onready var health_barr: Node2D = get_node("life_barr") 

func _ready() -> void:
	pass
#	$Panel.modulate = Color(1,1,1,1)
	

func handle_update_score(_value: int) -> void:
	#Convertimos a string y lo asignamos a label
	label_coin.text = String(_value)

func handle_update_health(_totalLife: int, _currentLife: int) -> void:
	# Actualizamos parametros de la barra de viad
	health_barr.update_health_barr(_currentLife,_totalLife)


