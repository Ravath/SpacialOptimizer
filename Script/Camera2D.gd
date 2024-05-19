extends Camera2D

# Dragging camera
var prev_position = Vector2(0,0)

func _process(_delta):
	if Input.is_action_just_pressed("drag_cam"):
		print("CAMERA")
		prev_position = get_local_mouse_position()
	if Input.is_action_pressed("drag_cam"):
		var p = get_local_mouse_position()
		self.position += (prev_position - p)
		prev_position = p
	if Input.is_action_just_pressed("zoom_in"):
		if zoom.x < 3 :
			zoom += Vector2(0.05, 0.05)
	if Input.is_action_just_pressed("zoom_out"):
		if zoom.x > 0.05 :
			zoom -= Vector2(0.05, 0.05)
	pass
