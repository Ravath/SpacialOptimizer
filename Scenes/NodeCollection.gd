extends Node2D

const MIN_FORCE = -10
const MAX_FORCE = 10
const VITESSE = 10

@export var pause_simulation = false

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
	if not pause_simulation :
		for f in center_forces:
			f.apply_forces()
		for f in forces:
			f.apply_forces()
	queue_redraw()

func swap_pause() :
	pause_simulation = !pause_simulation

func add_sim_node(new_position):
	var n = $TemplateNode.duplicate(DUPLICATE_SIGNALS|DUPLICATE_GROUPS|DUPLICATE_SCRIPTS|DUPLICATE_USE_INSTANTIATION)
	n.visible = true
	n.set_position(new_position)
	add_child(n)
	nodes.append(n)
	n.node_name = "RDN_" + str(nodes.size())
	
	# forces to keep into the monitor (debug)
	if get_node_or_null("Center") :
		center_forces.append(RigidForce.new($Center, n, int(float(VITESSE*MAX_FORCE) / 50)))
	
	# connect selection event
	n.connect("node_selected", get_parent().info_panel.set_node)

func remove_from_array(ar, el) :
	var index = ar.find(el)
	while index != -1 :
		ar.remove_at(index)
		index = ar.find(el)

func add_force(n1, n2, set_force) :
	if n1 == n2 :
		return
	# if one of the two is the center, use center_forces
	var work_array = forces
	if get_node_or_null("Center") :
		if n1 == $Center :
			work_array = center_forces
		elif n2 == $Center :
			work_array = center_forces
	# if force already exist : cumulate new force and existing force
	for f in work_array :
		if (f.targetA == n1 and f.targetB == n2) or (f.targetB == n1 and f.targetA == n2) :
			f.force += VITESSE*set_force
			return
	# Force desn't already exist : create new one
	work_array.append(RigidForce.new(n1, n2, VITESSE*set_force))

func delete_node(node_to_delete) :
	remove_from_array(nodes, node_to_delete)
	for f in node_to_delete.forces :
		remove_from_array(center_forces,f)
		remove_from_array(forces,f)
		if f.targetA != node_to_delete :
			remove_from_array(f.targetA.forces,f)
		else :
			remove_from_array(f.targetB.forces,f)
		f.targetA = null
		f.targetB = null
	node_to_delete.queue_free()

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
		
#		# add buddies
		var tn
		while nbrFriends> 0:
			tn = nodes[rng.randi() % nodes.size()]
			while tn == n :
				tn = nodes[rng.randi() % nodes.size()]
			add_force(n, tn, rng.randi_range(1, MAX_FORCE))
			nbrFriends -= 1
		
		# add ennemies
		while nbrFoes> 0:
			tn = nodes[rng.randi() % nodes.size()]
			while tn == n :
				tn = nodes[rng.randi() % nodes.size()]
			add_force(n, tn, rng.randi_range(MIN_FORCE, -1))
			nbrFoes -= 1
