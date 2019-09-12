extends RichTextLabel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
 
export (Vector2) var offset

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_position = get_parent().get_parent().get_parent().global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	