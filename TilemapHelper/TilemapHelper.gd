extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var TileArea
export (PackedScene) var ObservationLight
export (PackedScene) var RedLight
export (PackedScene) var DoorSound
export (PackedScene) var HatchSound
export (PackedScene) var ScreenSound

signal command_available()
signal command_unavailable()

signal hatch_available()
signal hatch_unavailable()

signal show_screen_message(message)

export (NodePath) var player_exp
export (NodePath) var tilemap_exp
export (NodePath) var navtilemap_exp
export (NodePath) var hatchslinktilemap_exp


export (Dictionary) var screens_text

const command_id : int = 8
const hatch_closed_id : int = 6
const hatch_open_id : int = 7
const door_closed_top_id : int = 14
const door_open_top_id : int = 15
const door_closed_bottom_id : int = 21
const door_open_bottom_id : int = 20
const screen_id : int = 1
const door_nav_tile : int = 58

const max_number_of_hatch_link : int = 25

onready var player : KinematicBody2D = get_node(player_exp)
onready var tilemap : TileMap = get_node(tilemap_exp)
onready var navtilemap : TileMap = get_node(navtilemap_exp)
onready var hatchslinktilemap : TileMap = get_node(hatchslinktilemap_exp)

onready var tileset : TileSet = tilemap.tile_set
onready var commands_tiles : Array = tilemap.get_used_cells_by_id(command_id)
onready var hatchs_tiles : Array = tilemap.get_used_cells_by_id(hatch_closed_id)

onready var redlight_tiles : Array = tilemap.get_used_cells_by_id(2)
onready var observationlight_tiles : Array = tilemap.get_used_cells_by_id(10)


var doors : Dictionary = {}
var doors_sound : Dictionary = {}
var screens : Dictionary = {}
var screens_sound : Dictionary = {}
var hatchs : Dictionary = {}
var hatchs_sound : Dictionary = {}

var hatchs_link : Dictionary = {}

var current_command_pos : Vector2 = Vector2(0,0)
var current_command_type : String = "none"

var current_hatch = null

func get_cell(pos : Vector2):
	return tilemap.get_cell(pos.x,pos.y)
	
	
func create_area(pos : Vector2) -> Area2D:
	var area2d : Area2D = TileArea.instance()
	add_child(area2d)
	area2d.global_position = pos*32
	return area2d

func create_hatch(pos : Vector2):
	hatchs[pos] = false
	hatchs_sound[pos] = HatchSound.instance()
	hatchs_sound[pos].global_position = pos*32
	hatchs_sound[pos].get_node("sound").connect("finished",self,"toogle_hatch",[pos])
	add_child(hatchs_sound[pos])
	return [pos,"hatch"]
	
func create_door(pos : Vector2):
	doors[pos] = false
	doors_sound[pos] = DoorSound.instance()
	doors_sound[pos].global_position = pos*32
	doors_sound[pos].get_node("sound").connect("finished",self,"toogle_door",[pos])
	add_child(doors_sound[pos])
	return [pos,"door"]
	
func create_screen(pos : Vector2):
	screens_sound[pos] = ScreenSound.instance()
	screens_sound[pos].global_position = pos*32
	screens_sound[pos].get_node("sound").connect("finished",self,"toogle_screen",[pos])
	add_child(screens_sound[pos])
	return [pos,"screen"]
	
func use_hatch():
	if current_hatch != null:
		var destination = hatchs_link[current_hatch]
		player.global_position = destination*32 + Vector2(16,16)
		var t = tilemap.get_cellv(destination)
		if t == hatch_closed_id:
			tilemap.set_cellv(destination,hatch_open_id)
			hatchs[destination] = true
			current_hatch = destination
		elif t != hatch_open_id:
			print ("sure that the destination tiles for ",current_hatch," is a hatch ?")
	
func toogle_hatch(pos):
	if hatchs[pos]:
		tilemap.set_cellv(pos,hatch_closed_id)
	else:
		tilemap.set_cellv(pos,hatch_open_id)
		
	hatchs[pos] = !hatchs[pos]
	
func toogle_door(pos):
	if doors[pos]:
		tilemap.set_cellv(pos,door_closed_bottom_id)
		tilemap.set_cell(pos.x,pos.y-1,door_closed_top_id)
		navtilemap.set_cellv(pos,-1)
		navtilemap.set_cell(pos.x,pos.y-1,-1)
		emit_signal("show_screen_message","Door closed")
	else:
		tilemap.set_cellv(pos,door_open_bottom_id)
		tilemap.set_cell(pos.x,pos.y-1,door_open_top_id)
		navtilemap.set_cellv(pos,door_nav_tile)
		navtilemap.set_cell(pos.x,pos.y-1,door_nav_tile)
		emit_signal("show_screen_message","Door open")
	
	navtilemap.update_bitmask_area(pos)	
	doors[pos] = !doors[pos]

func toogle_screen(pos):
	emit_signal("show_screen_message",screens_text[pos])
	
func toogle(pos,type):
	if type == "hatch":
		hatchs_sound[pos].get_node("sound").play()
	elif type == "door":
		doors_sound[pos].get_node("sound").play()
	elif type == "screen":
		screens_sound[pos].get_node("sound").play()
		
func toogle_command():
	toogle(current_command_pos,current_command_type)
	
func body_entered(body,type,param1,param2):
	if body != null and not body.get("I") == null:
		if body.I == "player":
			if type == "command":
				current_command_pos = param1
				current_command_type = param2
				emit_signal("command_available")
			elif type == "hatch":
				if hatchs[param1]:
					current_hatch = param1
					emit_signal("hatch_available")
	
func body_exited(body,type,param1,param2):
	if body != null and not body.get("I") == null:
		if body.I == "player":
			if body.I == "player":
				if type == "command":
					current_command_pos = Vector2(0,0)
					current_command_type = "none"
					emit_signal("command_unavailable")
				elif type == "hatch":
					if hatchs[param1] and current_hatch == param1:
						current_hatch = null
						emit_signal("hatch_unavailable")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	
	hatchslinktilemap.visible = false
	
	connect("command_available",player,"command_available")
	connect("command_unavailable",player,"command_unavailable")
	connect("hatch_available",player,"hatch_available")
	connect("hatch_unavailable",player,"hatch_unavailable")
	connect("show_screen_message",player,"receive_message_from_screen")
	player.connect("toogle_command",self,"toogle_command")
	player.connect("use_hatch",self,"use_hatch")
	
	for i in observationlight_tiles:
		var l = ObservationLight.instance()
		l.global_position = i*32 + Vector2(16,32)
		add_child(l)
	
	for i in redlight_tiles:
		var l = RedLight.instance()
		l.global_position = i*32 + Vector2(4,4)
		add_child(l)
	
	for i in hatchs_tiles:
		
		var area2d = create_area(i)
		area2d.connect("body_entered",self,"body_entered",["hatch",i,null])
		area2d.connect("body_exited",self,"body_exited",["hatch",i,null])
	
	
	for i in range(max_number_of_hatch_link):
		var link : Array = hatchslinktilemap.get_used_cells_by_id(i)
		if link.size() == 2:
			
			hatchs_link[link[0]] = link[1]
			hatchs_link[link[1]] = link[0]
	
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
		
		if element_commanded_type != "none": 
			var area2d = create_area(i)
			
			area2d.connect("body_entered",self,"body_entered",["command",element_commanded_pos,element_commanded_type])
			area2d.connect("body_exited",self,"body_exited",["command",element_commanded_pos,element_commanded_type])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
