extends CanvasLayer

# Nodos:
onready var label_coin:   Label = get_node("Control/CoinCounter/Label")
onready var label_lives:  Label = get_node("Control/CoinCounter/Label2")
onready var clock_label:  Label = get_node("Control/CoinCounter/Label3")
onready var health_barr: Node2D = get_node("Control/life_barr") 

func _ready() -> void:
	$Panel.modulate = Color(1,1,1,1)
	_on_Timer_timeout()
	scene_transition_fade()

func handle_update_score(_value: int) -> void:
	#Convertimos a string y lo asignamos a label
	label_coin.text = String(_value)

func handle_update_health(_totalLife: int, _currentLife: int) -> void:
	# Actualizamos parametros de la barra de vida
	health_barr.update_health_barr(_currentLife,_totalLife)

func handle_update_lives(_value) -> void:
	label_lives.text = String(_value)
	if _value == 0:
		$game_over_dialog.popup_centered()
# Funciona para oscurecer/aclarar la pantalla en la transicion de escenas
func scene_transition_fade(fade_in: bool = true ) -> void:
	# Cargamos en nodo tween en la variable tween
	var tween:Tween = get_node('Tween')
	# Creamos la variable color_in
	var color_in:  Color = Color(1,1,1,1)
	# Creamos la variable color_out
	var color_out: Color = Color(1,1,1,1)
	# Si fade in es verdadero
	if fade_in:
		# en color_in establecemos el Alpha en 1 
		color_in = Color(1,1,1,1)
		# en color_in establecemos el Alpha en 0
		color_out = Color(1,1,1,0)
	else:
		# en color_in establecemos el Alpha en 0 
		color_in = Color(1,1,1,0)
		# en color_in establecemos el Alpha en 1
		color_out = Color(1,1,1,1)
	# configuramos el nodo Tween
	# warning-ignore:RETURN_VALUE_DISCARDED
	tween.interpolate_property($Panel, "modulate",color_in, color_out, 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# Iniciamos la transicion
	# warning-ignore:RETURN_VALUE_DISCARDED
	tween.start()


func _on_Timer_timeout() -> void:
	# Obtenemos el tiempo transcurrido desde el inicio de la partida
	var time_now = int(GLOBAL.time_counter_ms)
	# Calculamos el tiempo transcurrido como la resta de:
		# > Tiempo ahora: el tiempo maquina en este momento
		# > Tiempo Offset: el tiempo de la partida guardada
		# Tiempo = tiempo_ahora + tiempo_offset
	var time_elapsed = time_now + GLOBAL.time_offset
	# guardamos el tiempo en la varible global de tiempo
	GLOBAL.current_time = time_elapsed
	# Damos formato de segundos transcurridos a: [min:seg] y lo mostramos en el label
	clock_label.text = format_time(time_elapsed)

func format_time(elapsed: int) -> String:
	# warning-ignore: INTEGER_DIVISION
	var minutes: int = int(float(elapsed / 60))
#	minutes = minutes / 60
	var seconds = elapsed % 60
	#minutes = minutes % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	return str_elapsed
