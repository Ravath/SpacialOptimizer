extends Node2D

# Dragging camera
var prev_position = Vector2(0,0)

func _on_ready():
	$Camera2D.position = get_window().size/2

func _process(_delta):
	if Input.is_action_just_pressed("drag_cam"):
		prev_position = get_local_mouse_position()
	if Input.is_action_pressed("drag_cam"):
		var p = get_local_mouse_position()
		self.position += (prev_position - p)
		prev_position = p
	if Input.is_action_just_pressed("zoom_in"):
		if $Camera2D.zoom.x < 3 :
			var s = $Camera2D/Info.size * $Camera2D/Info.scale
			$Camera2D.zoom += Vector2(0.05, 0.05)
			$Camera2D/Info.scale = Vector2(1.0/$Camera2D.zoom.x, 1.0/$Camera2D.zoom.y)
			var sa = $Camera2D/Info.size * $Camera2D/Info.scale
			position -= Vector2(
				(sa.x - s.x) / 2,
				(sa.y - s.y) / 2
			)
	if Input.is_action_just_pressed("zoom_out"):
		if $Camera2D.zoom.x > 0.1 :
			var s = $Camera2D/Info.size * $Camera2D/Info.scale
			$Camera2D.zoom -= Vector2(0.05, 0.05)
			$Camera2D/Info.scale = Vector2(1.0/$Camera2D.zoom.x, 1.0/$Camera2D.zoom.y)
			var sa = $Camera2D/Info.size * $Camera2D/Info.scale
			position -= Vector2(
				(sa.x - s.x) / 2,
				(sa.y - s.y) / 2
			)
