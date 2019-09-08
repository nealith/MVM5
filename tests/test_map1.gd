extends Node2D

onready var nav2d : Navigation2D = $Navigation2D
onready var sblorb : Node2D = $Sblorb
onready var tilemap : TileMap = $Navigation2D/TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_Sblorb_finish_move()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Sblorb_finish_move():
	var limits : Rect2 = tilemap.get_used_rect()
	randomize ()
	var x = randf() * (limits.size.x*32) + limits.position.x*32
	var y = randf() * (limits.size.y*32) + limits.position.y*32
	
	var new_path : = nav2d.get_simple_path(sblorb.global_position,Vector2(x,y))
	sblorb.path = new_path
