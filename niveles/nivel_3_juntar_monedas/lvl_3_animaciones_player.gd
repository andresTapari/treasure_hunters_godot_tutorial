extends Node2D

func _ready():
	# Conectamos la señal "update_score" de player con la función del HUD
	# que actualiza el puntaje
	$lvl_3_player.connect("update_score",$CanvasLayer,"handle_update_score")

