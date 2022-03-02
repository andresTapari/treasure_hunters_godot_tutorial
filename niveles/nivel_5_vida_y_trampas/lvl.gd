extends Node2D

export var id: String = ""

# creamos una variable para player
onready var player = get_node('lvl_5_player')

func _ready():
	# Conectamos la señal "update_score" de player con la función del HUD
	# que actualiza el puntaje
	player.connect("update_score",$CanvasLayer,"handle_update_score")
	# Conectamos la señal "update_score" de player con la función del HUD
	player.connect('update_health',$CanvasLayer,"handle_update_health")
