extends RigidBody2D

class_name RigidNode

signal node_selected(sel_node)

@onready var rad_sprite = $Area2D/radiance

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
	set_fixed(fixed)
	set_gravity(get_gravity())

func set_size(new_size) :
	size = new_size
	$Control.size = base_ctrl_size * size
	$Control.position = -$Control.size / 2
	$Sprite2D.scale = Vector2(size, size)
	$CollisionShape2D.scale = Vector2(size, size)
	$Area2D.scale = Vector2(size, size)
	#$Area2D.gravity_point_unit_distance = $Control.size.x / 2

func set_color(new_color) :
	color = new_color
	$Sprite2D.self_modulate  = color

func set_fixed(new_fixed) :
	fixed = new_fixed
	fixed_position = position
	$Sprite2D/FixedSprite.visible = fixed

func get_gravity() :
	return $Area2D.gravity

const MAX_G = 2000
const MIN_G = 2000
func set_gravity(new_gravity) :
	$Area2D.gravity = new_gravity
	var red   = 1 * -new_gravity / MAX_G if (new_gravity < 0) else 0
	var green = 1 *  new_gravity / MAX_G if (new_gravity > 0) else 0
	var c = Color(
		red,
		green,
		50,
		abs(new_gravity) / MAX_G
	)
	rad_sprite.self_modulate = c

func _process(_delta):
	# if is dragged by the mouse, follow the mouse position
	if drag :
		position = start_position + get_global_mouse_position() - drag_start_position
	elif fixed :
		position = fixed_position

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

func save() :
	var save_dict = {
		"node_name" : node_name,
		"position_x" : position.x,
		"position_y" : position.y,
		"size" : size,
		"gravity" : get_gravity(),
		"color" : color.to_html(),
		"fixed" : fixed
	}
	return save_dict

func load(load_dict) :
	node_name = load_dict["node_name"]
	position = Vector2(load_dict["position_x"], load_dict["position_y"])
	set_size(load_dict["size"])
	set_gravity(load_dict["gravity"])
	set_color(Color(load_dict["color"]))
	set_fixed(load_dict["fixed"])

