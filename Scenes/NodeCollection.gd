extends Node2D

const MIN_FORCE = -10
const MAX_FORCE = 10
const VITESSE = 10

var rng = RandomNumberGenerator.new()
var nodes = []
#export(Array, RigidForce)  (if its possible ...)
var forces = []
var center_forces = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	for f in forces:
		# draw the force (green=attraction / red=repulsion)
		var c = Color(0.1, 0.5, 0.1)
		var thickness = f.force / VITESSE
		if f.force < 0 :
			c = Color(0.5, 0.1, 0.1, 0.5)
			thickness = - thickness
		draw_line(f.targetA.position, f.targetB.position, c, thickness)

func _process(_delta):
	for f in center_forces:
		f.apply_forces()
	for f in forces:
		f.apply_forces()
	queue_redraw()

func add_sim_node(new_position):
	var n = $TemplateNode.duplicate(DUPLICATE_SIGNALS|DUPLICATE_GROUPS|DUPLICATE_SCRIPTS|DUPLICATE_USE_INSTANTIATION)
	n.visible = true
	n.set_position(new_position)
	add_child(n)
	nodes.append(n)
	n.node_name = "RDN_" + str(nodes.size())
	
	# forces to keep into the monitor (debug)
	center_forces.append(RigidForce.new($Center, n, VITESSE*MAX_FORCE / 500))
	
	# connect selection event
	n.connect("node_selected", get_parent().info_panel.set_node)

func create_test_nodes():
	rng.randomize()
	
	var NBR_NODES = 10
	var NBR_FRIENDS = 2
	var NBR_FOES = 3
	
	var spwansize = Vector2(1600,800)
	
	# instanciate a bunch of nodes
	for _i in range(NBR_NODES):
		var randX = rng.randf_range(0.0, spwansize.x) - spwansize.x/2
		var randY = rng.randf_range(0.0, spwansize.y) - spwansize.y/2
		add_sim_node(Vector2(randX, randY))
	
	# link the nodes with forces
	for n in nodes:
		var nbrFriends = NBR_FRIENDS
		var nbrFoes = NBR_FOES
		# full rand formula
#		n.add_force(Force.new(tn, (rng.randi() % (MAX_FORCE - MIN_FORCE + 1)) + MIN_FORCE))
		
#		# add buddy
		var tn
		while nbrFriends> 0:
			tn = nodes[rng.randi() % nodes.size()]
			while tn == n :
				tn = nodes[rng.randi() % nodes.size()]
			forces.append(RigidForce.new(n, tn, VITESSE*rng.randi_range(1, MAX_FORCE)))
			nbrFriends -= 1
		
		# add ennemy
		while nbrFoes> 0:
			tn = nodes[rng.randi() % nodes.size()]
			while tn == n :
				tn = nodes[rng.randi() % nodes.size()]
			forces.append(RigidForce.new(n, tn, VITESSE*rng.randi_range(MIN_FORCE, -1)))
			nbrFoes -= 1
