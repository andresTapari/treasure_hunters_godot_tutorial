extends KinematicBody2D

# Nodos:
# Variables:
export var position_target_A: NodePath			# Coordenadas hasta donde patrullar
export var position_target_B: NodePath			# Coordenadas hasta donde patrullar
export var idle_time: int   = 1
export var travel_time: int = 2
var patrol_target_A: Vector2 = Vector2.ZERO
var patrol_target_B: Vector2 = Vector2.ZERO
var check_top_crush: bool = false
var target_node: Node = null

func _ready() -> void:
	if !position_target_A.is_empty() and !position_target_B.is_empty():
		# Se asigna a la patrol_target_A la posision de A
		patrol_target_A = get_node(position_target_A).position
		# Se asigna a la patrol_target_A la posision de B
		patrol_target_B = get_node(position_target_B).position
		$Timer.wait_time = idle_time
		$Timer.start()

func _physics_process(delta: float) -> void:
	if check_top_crush:
		if target_node and target_node.is_in_group("player"):
			if target_node.is_under_ceiling():
				target_node.hit(999)

func _on_Timer_timeout() -> void:
	var dist_to_a: float = global_position.distance_to(patrol_target_A)
	var dist_to_b: float = global_position.distance_to(patrol_target_B)
	var target_position: Vector2 = Vector2.ZERO
	if dist_to_a > dist_to_b:
		target_position = patrol_target_A
	else:
		target_position = patrol_target_B
	var tween = get_node("Tween")
	tween.interpolate_property(self, "global_position",
		global_position, target_position, travel_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,'tween_all_completed')
	$Timer.start()



func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.is_on_floor():
			body.hit(999)
			target_node = null
			check_top_crush = false

func _on_Area2D_top_body_entered(body: Node) -> void:
	target_node = body
	check_top_crush = true


func _on_Area2D_top_body_exited(body: Node) -> void:
	target_node = null
	check_top_crush = false
