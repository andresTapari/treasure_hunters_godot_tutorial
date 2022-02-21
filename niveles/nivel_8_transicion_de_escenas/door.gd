extends Area2D

# Señales:
signal fade_out(_boolean)

# Nodos:
onready var animatedSprite: AnimatedSprite = get_node('AnimatedSprite')

# Variables
export(String, FILE,"*.tscn") var next_lvl		# Direccion de la siguiente escena
export var door_indx: 		int = 0				# Indentificador propio de la puerta
export var next_door_indx:	int = 0				# Indentificador de la siguiente puerta donde player aparecera

var target_lvl: String							# Path hacia el siguiente nivel
var current_scene								# Escena actual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# cargamos el nodo raiz del juego en root
	var root = get_tree().get_root()
	# cargamos la escena actual en current_scene
	current_scene = root.get_child(root.get_child_count() - 1)
	# si el siguiente nivel no esta vacio
	if !next_lvl.empty():
		# establecemos target_lvl como el siguiente nivel
		target_lvl = next_lvl

# Funcion se ejecuta cuando el jugador interactua con la puerta
func hit(_damage:int ,_direction:Vector2) -> void:
	# Reproducimos animacion de abrir puerta
	animatedSprite.play("opening")
	# Establecemos el indice de la puerta donde el jugador debe aparecer
	GLOBAL.next_lvl_door_indx = next_door_indx
	# Emitimos la señal para oscurecer la pantalla
	emit_signal('fade_out',false)
	# Esperamos que la animacion de la puerta termine
	yield(animatedSprite,"animation_finished")
	# llamamos a la funcion cambair escena
	GLOBAL.change_current_scene(target_lvl)
