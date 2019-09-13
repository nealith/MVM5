extends Node2D

export (PackedScene) var Sblorb
export (NodePath) var player_exp
export (NodePath) var nav2d_exp
export (NodePath) var tilemap_exp
export (NodePath) var spawnstilemap_exp


onready var player : KinematicBody2D = get_node(player_exp)
onready var nav2d : Navigation2D = get_node(nav2d_exp)
onready var tilemap : TileMap = get_node(tilemap_exp)
onready var spawnstilemap : TileMap = get_node(spawnstilemap_exp)

const red_sblorb_id : int = 0
const sblorb_id : int = 1

onready var sblorbs : Array = spawnstilemap.get_used_cells_by_id(sblorb_id)
onready var red_sblorbs : Array = spawnstilemap.get_used_cells_by_id(red_sblorb_id)

var sblorb_instances : Array = []
var red_sblorb_instances : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnstilemap.visible = false
	
	print (sblorbs)
	print (red_sblorbs)
	
	for p in sblorbs:
		var s : Node2D = Sblorb.instance()
		s.global_position = nav2d.get_closest_point(p*32 + Vector2(16,16))
		sblorb_instances.append(s)
		if player != null:
			s.connect("hit_player",player,"hitten")
		s.connect("finish_move",self,"_finish_moving",["sblorb"])
		add_child(s)
	
	for p in red_sblorbs:
		var s : Node2D = Sblorb.instance()
		s.global_position = nav2d.get_closest_point(p*32 + Vector2(16,16))
		s.type = "red_sblorb"
		sblorb_instances.append(s)
		if player != null:
			s.connect("hit_player",player,"hitten")
		s.connect("finish_move",self,"_finish_moving",["red_sblorb"])
		add_child(s)

func check_path(origine : Vector2,destination : Vector2) -> bool:
	var p :=  nav2d.get_simple_path(origine,destination)
	return (p.size() > 0 and  p[p.size()-1] == destination)

func _finish_moving(sblorb,type):
	if tilemap != null and nav2d != null:
		var map_limits : Rect2 = tilemap.get_used_rect()
		
		
		var limits : Rect2 = Rect2(nav2d.get_closest_point(map_limits.position),nav2d.get_closest_point(map_limits.position+map_limits.size))
		
		var loop : bool = true
		var new_path
		while(loop):
			
			var wanted_destination : Vector2
			var destination : Vector2
			
			if type == "red_sblorb":
				
				wanted_destination = player.global_position

				destination = nav2d.get_closest_point(wanted_destination)
				
				new_path = nav2d.get_simple_path(sblorb.global_position,wanted_destination,false)
				if new_path.size() == 0 or new_path[new_path.size()-1] < wanted_destination + Vector2(-16,-16) or new_path[new_path.size()-1] > wanted_destination + Vector2(16,16) :
					type = "sblorb"
	
			
			if type == "sblorb":
		
				randomize ()
				wanted_destination = Vector2(randf() * (limits.size.x*32) + limits.position.x*32,randf() * (limits.size.y*32) + limits.position.y*32)
				destination = nav2d.get_closest_point(wanted_destination)
			
				new_path = nav2d.get_simple_path(sblorb.global_position,destination)
			
			loop = !(new_path.size() > 0)
		
		sblorb.path = new_path