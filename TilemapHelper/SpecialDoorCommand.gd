extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Vector2) var position_of_door

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().create_door(position_of_door)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	get_parent().body_entered(body,"command",position_of_door,"door")


func _on_Area2D_body_exited(body):
	get_parent().body_exited(body,"command",position_of_door,"door")
