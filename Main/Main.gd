extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player_start_position : Vector2 = $Player.global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_dead():
	$Player.global_position = player_start_position
	$Player/AnimatedSprite.animation = "idle"
	$Player.set_physics_process(true)
