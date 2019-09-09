extends Node2D

export (PackedScene) var Sblorb
export (NodePath) var player_exp
export (NodePath) var nav2d_exp
export (NodePath) var tilemap_exp
export (PoolVector2Array) var positions


onready var player : KinematicBody2D = get_node(player_exp)
onready var nav2d : Navigation2D = get_node(nav2d_exp)
onready var tilemap : TileMap = get_node(tilemap_exp)
var sblorb_instances : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(positions.size()):
		var s : Node2D = Sblorb.instance()
		s.global_position = positions[i]
		sblorb_instances.append(s)
		if player != null:
			s.connect("hit_player",player,"hitten")
		s.connect("finish_move",self,"_finish_moving")
		add_child(s)

func _finish_moving(sblorb):
	print("ddddeeeeee")
	if tilemap != null and nav2d != null:
		var limits : Rect2 = tilemap.get_used_rect()
		
		var loop : bool = true
		var new_path
		while(loop):
		
			randomize ()
			var x = randf() * (limits.size.x*32) + limits.position.x*32
			var y = randf() * (limits.size.y*32) + limits.position.y*32
			
			var destination : Vector2 = nav2d.get_closest_point(Vector2(x,y))
			
			print (sblorb.global_position)
			print (destination)
			
			new_path = nav2d.get_simple_path(sblorb.global_position,destination)
			
			print (new_path)
			loop = !(new_path.size() != 0)
			
		sblorb.path = new_path