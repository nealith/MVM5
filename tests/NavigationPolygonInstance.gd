extends NavigationPolygonInstance

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	self.navpoly = get_parent().get_node("TileMap").tile_set.tile_get_navigation_polygon(
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
