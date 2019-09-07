extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity = Vector2()
var direction = "none"

const SPEED = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	print(direction)
	if direction != "none":
		if direction == "up":
			velocity = Vector2(0,-SPEED)
		elif direction == "down":
			velocity = Vector2(0,SPEED)
		elif direction == "left":
			velocity = Vector2(-SPEED,0)
		elif direction == "right":
			velocity = Vector2(SPEED,0)
			
		var collision = move_and_collide(velocity*delta)
		if collision:
			get_parent().remove_child(self)