extends Node2D

const SPEED : = 50.0
var path : = PoolVector2Array() setget set_path

signal finish_move()
signal hitten()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	var move_distance : = SPEED * delta
	move_along_path(move_distance)

func move_along_path(distance : float) -> void:
	var start_point : = global_position
	
	for i in range(path.size()):
		var distance_to_next := start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			global_position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance < 0.0:
			global_position = path[0]
			set_process(false)
			emit_signal("finish_move")
			break
			
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
	
	if path.size() == 0:
		set_process(false)
		emit_signal("finish_move")

func set_path(value : PoolVector2Array) -> void:
	path = value
	if value.size() != 0:
		set_process(true)

func _on_Area2D_body_entered(body : PhysicsBody2D):
	if body != null and not body.get("iname") == null and body.iname == "bullet":
		emit_signal("hitten")
		get_parent().remove_child(self)
