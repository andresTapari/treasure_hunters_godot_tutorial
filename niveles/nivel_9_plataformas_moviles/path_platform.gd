extends PathFollow2D

export var speed : int = 200

func _physics_process(delta: float) -> void:
	# por cada ciclo de _pyhsics_process movemos la plataforma sobre el camino
	set_offset(get_offset() + speed*delta)
	
