extends Node2D

onready var nav2d : Navigation2D = $Navigation2D
onready var tilemap : TileMap = $Navigation2D/TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass