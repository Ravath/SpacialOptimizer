extends RigidBody2D

class_name RigidNode

signal node_selected(sel_node)

@export var fixed = false
@export var size  = 1.0 # (float, 1, 10, 0.1)
@export var color = Color.RED
# User Data
@export var node_name = "NODE"

var drag = false
var start_position = Vector2(0, 0)
var drag_start_position = Vector2(0, 0)
var controlSize

var base_ctrl_size

# Called when the node enters the scene tree for the first time.
func _ready():
	base_ctrl_size = $Control.size
	set_size(size)
	set_color(color)
	if fixed :
		#self.set_mode( FREEZE_MODE_STATIC )
		self.set_freeze.mode(RigidBody2D.FREEZE_MODE_STATIC) 
	pass # Replace with function body.

func set_size(new_size) :
	size = new_size
	$Control.size = base_ctrl_size * size
	$Control.position = -$Control.size / 2
	$Sprite2D.scale = Vector2(size, size)
	$CollisionShape2D.scale = Vector2(size, size)
	$Area2D.scale = Vector2(size, size)

func set_color(new_color) :
	color = new_color
	$Sprite2D.modulate  = color

func _process(_delta):
	pass
	# if is dragged by the mouse, follow the mouse position
	if drag :
		position = start_position + get_global_mouse_position() - drag_start_position
#
func _on_Control_gui_input(event):
	if event is InputEventMouseButton :
		# If pressed by the mouse, start dragging
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
			drag = true
			drag_start_position = get_global_mouse_position()
			start_position = position
			node_selected.emit(self)
		# If released  by the mouse, stop dragging
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
			drag = false
