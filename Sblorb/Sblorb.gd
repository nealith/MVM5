extends KinematicBody2D

const SPEED : = 50.0
var path : = PoolVector2Array() setget set_path


signal finish_move(sblorb)
signal hitten()
signal hit_player()

var type = "normal"

var default_animation = "default"
var dead_animation = "dead"

var velocity

const MAX_ATTEMPS = 5
var attemps_counter = 0
var old_distance = -1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == "red":
		default_animation = "red_default"
		dead_animation = "red_dead"
	$AnimatedSprite.animation = default_animation
	
	set_process(false)
	emit_signal("finish_move",self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	
	if path.size() > 0:
		velocity = (path[0] - position).normalized() * SPEED
		var distance = (path[0] - position).length()
		if distance > 4: # value from https://godotengine.org/qa/40991/moving-colliding-multiple-objects-on-a-nav2d-tilemap
            move_and_slide(velocity)
		else:
			path.remove(0)
			
		if distance == old_distance:
			print("ho my god")
			attemps_counter+=1
			if attemps_counter == MAX_ATTEMPS:
				old_distance = -1
				attemps_counter = 0
				path = []
			
		old_distance = distance
	else:
		emit_signal("finish_move",self)
		set_physics_process(false)

func set_path(value : PoolVector2Array) -> void:
	path = value
	if value.size() != 0:
		set_physics_process(true)

func _on_Area2D_body_entered(body : PhysicsBody2D):
	if body != null and not body.get("I") == null:
		if body.I == "bullet":
			emit_signal("hitten")
			set_physics_process(false)
			$AnimatedSprite.animation = dead_animation
			
		elif body.I == "player" and $AnimatedSprite.animation != dead_animation:
			set_physics_process(false)
			emit_signal("hit_player")
			get_parent().remove_child(self)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == dead_animation:
		get_parent().remove_child(self)
