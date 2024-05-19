extends Control

const MIN_FORCE = -10
const MAX_FORCE = 10
var rng = RandomNumberGenerator.new()
var nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	# instanciate a bunch of nodes
	for i in range(10):
		var screen_size = get_viewport().size
		var randX = rng.randf_range(0.0, screen_size.x)
		var randY = rng.randf_range(0.0, screen_size.y)
		add_node(Vector2(randX, randY))
	
	# link the nodes with forces
	for n in nodes:
		# full rand formula
#		n.add_force(Force.new(tn, (rng.randi() % (MAX_FORCE - MIN_FORCE + 1)) + MIN_FORCE))
		
		# add buddy
		var tn = nodes[rng.randi() % nodes.size()]
		while tn == n :
			tn = nodes[rng.randi() % nodes.size()]
		n.apply_force(Force.new(tn, rng.randi_range(0, MAX_FORCE)))
		
		# add ennemy
		tn = nodes[rng.randi() % nodes.size()]
		while tn == n :
			tn = nodes[rng.randi() % nodes.size()]
		n.apply_force(Force.new(tn, rng.randi_range(MIN_FORCE, 0)))

func _process(delta):
	update()

func _draw():
	for n in nodes:
		var first = false
		for f in n.array:
			if first : 
				# don't draw the first force (to the center of the system)
				first = false
			else :
				# draw the force (green=attraction / red=repulsion)
				var c = Color(0.1, 0.5, 0.1)
				if f.force < 0 :
					c = Color(0.5, 0.1, 0.1)
				draw_line(n.position, f.target.position, c)

func _on_Interface_gui_input(event):
	if event is InputEventMouseButton :
		# Add a node where LEFT_MOUSSE_BUTTON
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT :
			add_node(event.position)
		else : 
			print(event)
	elif not event is InputEventMouseMotion :
		print(event)

func add_node(position):
	var n = $NodeControl.duplicate()
	n.visible = true
	n.set_position(position)
	add_child(n)
	nodes.append(n)
