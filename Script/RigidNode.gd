extends RigidBody2D

class_name RigidNode

signal node_selected(sel_node)

# User Data
@export var node_name = "NODE"
@export var size  = 1.0 # (float, 1, 10, 0.1)
@export var color = Color.RED
@export var fixed = false
var forces = []

# drag data
var drag = false
var start_position = Vector2(0, 0)
var drag_start_position = Vector2(0, 0)
# resize data
var base_ctrl_size
# fixed data
var fixed_position


# Called when the node enters the scene tree for the first time.
func _ready():
	base_ctrl_size = $Control.size
	set_size(size)
	set_color(color)
	if fixed :
		fixed_position = self.position
		#self.set_mode( FREEZE_MODE_STATIC )
		#self.set_freeze.mode(RigidBody2D.FREEZE_MODE_STATIC) 
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

func set_fixed(new_fixed) :
	fixed = new_fixed
	fixed_position = position

var s = 0
var mouse_over = false
func _process(_delta):
	# if is dragged by the mouse, follow the mouse position
	if drag :
		position = start_position + get_global_mouse_position() - drag_start_position
	elif fixed :
		position = fixed_position
	#if node_name == "CENTER" :
		#if mouse_over:
			#print("OVER")
		#else :
			#print("NOT")
	mouse_over = false
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
			fixed_position = self.position
	else :
		mouse_over = true
