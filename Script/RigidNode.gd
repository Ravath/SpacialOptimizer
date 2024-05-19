extends RigidBody2D

class_name RigidNode

@export var fixed = false
@export var size  = 1.0 # (float, 1, 10, 0.1)
@export var color = Color.RED

var drag = false
var start_position = Vector2(0, 0)
var drag_start_position = Vector2(0, 0)
var controlSize

# User Data
var node_name = "NODE"

# Called when the node enters the scene tree for the first time.
func _ready():
	controlSize = $Control.size
	$Control.size = controlSize * size
	$Sprite2D.scale = Vector2(size, size)
	$CollisionShape2D.scale = Vector2(size, size)
	$Area2D.scale = Vector2(size, size)
	$Sprite2D.modulate  = color
	if fixed :
		#self.set_mode( FREEZE_MODE_STATIC )
		self.set_freeze.mode(RigidBody2D.FREEZE_MODE_STATIC) 
	pass # Replace with function body.

func _process(_delta):
	pass
	# if is dragged by the mouse, follow the mouse position
	if drag :
		position = start_position + get_global_mouse_position() - drag_start_position
#
func _on_Control_gui_input(event):
	if event is InputEventMouseButton :
		# If pressed by the mouse, start dragging
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			drag = true
			drag_start_position = get_global_mouse_position()
			start_position = position
		# If released  by the mouse, stop dragging
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
			drag = false
