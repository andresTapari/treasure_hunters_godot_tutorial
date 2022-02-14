extends Area2D

# Variables
export (PackedScene) var to_lvl

var target_lvl: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !to_lvl.is_empty():
		target_lvl = to_lvl



