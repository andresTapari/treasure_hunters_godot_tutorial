extends MarginContainer

export var self_indx: int

var empty: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	GLOBAL.save_data(self_indx,"")
