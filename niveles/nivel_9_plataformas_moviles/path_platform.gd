extends PathFollow2D

export var speed : int = 200


func _physics_process(delta: float) -> void:
	set_offset(get_offset() + speed*delta)
	
