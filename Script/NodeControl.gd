extends CharacterBody2D

var rng = RandomNumberGenerator.new()

var array = []
const FORCE_TO_CENTER_FACTOR = 0.1
const ACCEL_FACTOR = 0.01
const RAND_FACTOR = 0.005

const MAX_SPEED = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


func _process(delta):
	if drag :
		position = get_global_mouse_position()
	else:
		# slight force towards center to keep into screen
		move_and_collide(FORCE_TO_CENTER_FACTOR * ((get_viewport_rect().size / 2) - position))
		
		# a random noise force
		var rv = Vector2.UP
		move_and_collide(RAND_FACTOR * rv.rotated(rng.randf_range(0, 2*PI)))
		
		# apply every other forces
		for f in array:
			var v = f.target.position - position
			v = v * ACCEL_FACTOR * f.force
			if v.length() > MAX_SPEED:
				v = v.normalized() * MAX_SPEED
			move_and_collide(v)

var drag = false

func _on_Control_gui_input(event):
	if event is InputEventMouseButton :
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
			drag = true
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
			drag = false

func apply_force(force : Force):
	array.append(force)

