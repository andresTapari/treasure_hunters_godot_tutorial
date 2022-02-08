extends Node2D

func update_health_barr(_value: int, _total: int) -> void:
	# Establecemos el total de la vida
	$TextureProgress.max_value = _total
	# Establecemos el valor actual
	$TextureProgress.value=_value


