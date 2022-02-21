extends MarginContainer

# Señales:
signal button_pressed(_index) #WindowDialog_slot_dialog->handle_button_pressed()

# Nodos:
onready var label_name		= get_node("Button/VBoxContainer/HBoxContainer/Label")
#onready var icon_thumbnail	= get_node("Button/VBoxContainer/ViewportContainer/Viewport/TextureRect")
onready var icon_thumbnail	= get_node("Button/VBoxContainer/HBoxContainer4/ViewportContainer/Viewport/TextureRect")
onready var label_score		= get_node("Button/VBoxContainer/HBoxContainer2/Label_score")
onready var label_time		= get_node("Button/VBoxContainer/HBoxContainer3/Label_time")

# Variables:
export var self_indx: int
var empty: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_data(saved_data:Dictionary) -> void:
	empty = false
	label_name.text  = saved_data["slot_name"]
	label_score.text = String(saved_data["current_score"])
	label_time.text  = format_time(saved_data["current_time"])
	var image = Image.new()
	var err = image.load(saved_data["thumbnail_path"])
	if err != OK:
		print_debug("ERROR CARGANDO THUMBNAIL")
	var texture = ImageTexture.new()
	texture.create_from_image(image,8)
	icon_thumbnail.texture = texture

func _on_Button_pressed():
	emit_signal('button_pressed',self_indx, empty)

func format_time(elapsed: int) -> String:
	var minutes: int = int(float(elapsed / 60))
#	minutes = minutes / 60
	var seconds = elapsed % 60
	#minutes = minutes % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	return str_elapsed
