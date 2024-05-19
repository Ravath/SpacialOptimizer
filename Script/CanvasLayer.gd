extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	# Ensure the UI layer follows the camera's position
	#self.transform = get_viewport().get_camera_2d().transform
	#self.transform.origin = -get_viewport().get_camera_2d().position
	#self.transform.scale = get_viewport().get_camera_2d().scale
	pass
