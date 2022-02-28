extends MarginContainer

# Señales:
signal button_pressed(_index) #WindowDialog_slot_dialog->handle_button_pressed()

# Nodos:
onready var label_name		= get_node("Button/VBoxContainer/HBoxContainer/Label")
onready var label_date		= get_node("Button/VBoxContainer/HBoxContainer5/Label")
onready var icon_thumbnail	= get_node("Button/VBoxContainer/HBoxContainer4/ViewportContainer/Viewport/TextureRect")
onready var label_score		= get_node("Button/VBoxContainer/HBoxContainer2/Label_score")
onready var label_time		= get_node("Button/VBoxContainer/HBoxContainer3/Label_time")

# Variables:
export var self_indx: 	int
var empty: 				bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_data(saved_data:Dictionary) -> void:
	# establecemos la bandera de vacio en falso
	empty = false
	# establecemos en el label la informacion contenida en "slot_name"
	label_name.text  = saved_data["slot_name"]
	# establecemos la fecha de la partida guardada
	label_date.text  = saved_data["date"]
	# establecemos en el label la informacion contenida en "current_score"
	label_score.text = String(saved_data["current_score"])
	# establecemos en el label la informacion contenida en "current_time"
	label_time.text  = format_time(saved_data["current_time"])
	# creamos una instancia de la clase Image
	var image = Image.new()
	# cargamos la imagen guardada en "thumbnail_path"
	var err = image.load(saved_data["thumbnail_path"])
	# si no devuelve error
	if err != OK:
		# mostramos error de cargando miniatura
		print_debug("ERROR CARGANDO THUMBNAIL")
	# creamos una instancia nueva de la clase textura 
	var texture = ImageTexture.new()
	# asignamos a la nueva textura la imagen
	texture.create_from_image(image,8)
	# establecemos en la textura del icono, la nueva textura creada con la imagen
	icon_thumbnail.texture = texture

func _on_Button_pressed():
	emit_signal('button_pressed',self_indx, empty)

func format_time(elapsed: int) -> String:
	#warning-ignore:INTEGER_DIVISION
	var minutes: int = int(float(elapsed / 60))
#	minutes = minutes / 60
	var seconds = elapsed % 60
	#minutes = minutes % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	return str_elapsed
