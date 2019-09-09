extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var TileArea

signal command_available()
signal command_unavailable()

export (NodePath) var player_exp
export (NodePath) var tilemap_exp

const command_id : int = 8
const hatch_closed_id : int = 6
const hatch_open_id : int = 7
const door_closed_top_id : int = 14
const door_open_top_id : int = 15
const door_closed_bottom_id : int = 21
const door_open_bottom_id : int = 20
const screen_id : int = 1

onready var player : KinematicBody2D = get_node(player_exp)
onready var tilemap : TileMap = get_node(tilemap_exp)
onready var tileset : TileSet = tilemap.tile_set
onready var commands_tiles : Array = tilemap.get_used_cells_by_id(8)

var doors : Dictionary = {}
var screens : Dictionary = {}
var hatchs : Dictionary = {}

var current_command_pos : Vector2 = Vector2(0,0)
var current_command_type : String = "none"


func get_cell(pos : Vector2):
	return tilemap.get_cell(pos.x,pos.y)
	
	
func create_area(pos : Vector2) -> Area2D:
	var area2d : Area2D = TileArea.instance()
	add_child(area2d)
	area2d.global_position = pos*32
	return area2d

func create_hatch(pos : Vector2):
	hatchs[pos] = false
	return [pos,"hatch"]
	
func create_door(pos : Vector2):
	doors[pos] = false
	return [pos,"door"]
	
func create_screen(pos : Vector2):
	screens[pos] = false
	return [pos,"screen"]
	
func toogle_hatch(pos):
	print("toogle hatch")
	
func toogle_door(pos):
	print("toogle door")

func toogle_screen(pos):
	print("toogle screen")
	
func toogle(pos,type):
	if type == "hatch":
		toogle_hatch(pos) 
	elif type == "door":
		toogle_door(pos)
	elif type == "screen":
		toogle_screen(pos)
		
func toogle_command():
	toogle(current_command_pos,current_command_type)
	
func body_entered(body,pos,type):
	if body != null and not body.get("I") == null:
		if body.I == "player":
			current_command_pos = pos
			current_command_type = type
			emit_signal("command_available")
	
func body_exited(body,pos,type):
	if body != null and not body.get("I") == null:
		if body.I == "player":
			current_command_pos = Vector2(0,0)
			current_command_type = "none"
			emit_signal("command_unavailable")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	connect("command_available",player,"command_available")
	connect("command_unavailable",player,"command_unavailable")
	player.connect("toogle_command",self,"toogle_command")
	
	for i in commands_tiles:
		
		var left = Vector2(i.x-1,i.y)
		var right = Vector2(i.x+1,i.y)
		var top = Vector2(i.x,i.y-1)		
		
		var tmp = [Vector2(0,0),"none"]
		
		if get_cell(left) == hatch_closed_id:
			tmp = create_hatch(left)
		elif get_cell(right) == hatch_closed_id:
			tmp = create_hatch(right)
		elif get_cell(left) == door_closed_bottom_id:
			tmp = create_door(left)
		elif get_cell(right) == door_closed_bottom_id:
			tmp = create_door(right)
		elif get_cell(top) == screen_id:
			tmp = create_screen(top)
			
		var element_commanded_pos : Vector2 = tmp[0]
		var element_commanded_type : String = tmp[1]
			
		print(element_commanded_pos)
		
		if element_commanded_type != "none":
			
			print(element_commanded_type) 
			var area2d = create_area(i)			
			
			area2d.connect("body_entered",self,"body_entered",[element_commanded_pos,element_commanded_type])
			area2d.connect("body_exited",self,"body_exited",[element_commanded_pos,element_commanded_type])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
