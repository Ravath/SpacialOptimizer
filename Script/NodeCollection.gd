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

func get_by_node_name(nm) :
	for n in nodes :
		if n.node_name == nm :
			return n
	if $Center.node_name == nm :
		return $Center

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
	for n in nodes :
		n.freeze = pause_simulation

func new_node() :
	var n = $TemplateNode.duplicate(DUPLICATE_SIGNALS|DUPLICATE_GROUPS|DUPLICATE_SCRIPTS|DUPLICATE_USE_INSTANTIATION)
	n.visible = true
	add_child(n)
	# connect selection event
	n.connect("node_selected", get_parent().info_panel.set_node)
	n.freeze = pause_simulation
	return n

func add_sim_node(new_position):
	var n = new_node()
	n.set_position(new_position)
	nodes.append(n)
	n.node_name = "RDN_" + str(nodes.size())
	
	# forces to keep into the monitor (debug)
	if get_node_or_null("Center") :
		center_forces.append(RigidForce.new($Center, n, int(float(VITESSE*MAX_FORCE) / 50)))
	
	return n

func get_node_from_model(node_model) :
	var dupl_node = add_sim_node(node_model.position + Vector2(2,2))
	dupl_node.set_color(node_model.color)
	dupl_node.set_size(node_model.size)
	dupl_node.set_fixed(node_model.fixed)
	dupl_node.set_gravity(node_model.get_gravity())
	return dupl_node

func duplicate_node(node_model) :
	var dupl_node = get_node_from_model(node_model)
	dupl_node.node_name = node_model.node_name + "_D"
	# copy forces
	for f in node_model.forces :
		add_force(dupl_node, f.other(node_model), f.force/VITESSE)
	# add repulsive forces for them to be 'distinct'
	add_force(dupl_node, node_model, -5)

func split_node(node_model) :
	var clock = []
	var misc = []
	for f in node_model.forces :
		if f.force > 0 and not f.center_force():
			var direction = f.other(node_model).position - node_model.position
			var angle = direction.angle() # RADIAN
			clock.append([angle, f])
		else :
			misc.append(f)
	if clock.size() <= 1 :
		pass
	elif clock.size() == 2 :
		var split_node = get_node_from_model(node_model)
		split_node.node_name = node_model.node_name + "_S"
		# copy repulsive and center forces
		for f in misc :
			if f.force < 0 :
				add_force(split_node, f.other(node_model), f.force/VITESSE)
		# one attractive force for each
		var permute = clock[0][1]
		permute.change(node_model, split_node)
	else :
		var si = find_best_split_index(clock)
		var split_node = get_node_from_model(node_model)
		split_node.node_name = node_model.node_name + "_S"
		# copy repulsive and center forces
		for f in misc :
			if f.force < 0 :
				add_force(split_node, f.other(node_model), f.force/VITESSE)
		# one attractive force for each
		for i in range(0,si) :
			var permute = clock[i][1]
			permute.change(node_model, split_node)

func find_best_split_index(clock) :
	clock.sort_custom(func custom_comparison(a,b) : return a[0] < b[0])
	return clock.size() / 2
	# TODO implement auto split
	# Auto split intent : test every split angle, and use the one with :
	# - separating the forces in two groups of similar size
	# - the 2 normal vectors of the split have the minimum Standard deviation 
	#	with the vectors of the group pf same orientation.
	#	(the sum of the 2 SD is minimum)
	#var best = clock.size()
	#var best_index = 0
	#var index0
	#var index1
	#for c in clock :
		#index1 = index0 + 1
		#for i in range(index1, clock.size()) :
			#if clock[i][0] > c[0] :
				#var score = i - index0
		#var target = c[0] + PI/2
		#index0 +=1
	#return 0

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

func reset() :
	for n in nodes :
		n.queue_free()
	nodes.clear()
	forces.clear()
	center_forces.clear()
	if not get_node_or_null("Center") :
		var n = $TemplateNode.duplicate(DUPLICATE_SIGNALS|DUPLICATE_GROUPS|DUPLICATE_SCRIPTS|DUPLICATE_USE_INSTANTIATION)
		n.visible = true
		n.name = "Center"
		add_child(n, true)
		# connect selection event
		n.connect("node_selected", get_parent().info_panel.set_node)
	else :
		$Center.forces.clear()
	$Center.set_position(Vector2(0, 0))
	$Center.set_size(2)
	$Center.set_fixed(true)
	$Center.node_name = "CENTER"

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

func _on_reset_gravity_pressed():
	for n in nodes :
		n.set_gravity(0)
	$Center.set_gravity(0)


func _on_general_gravity_value_changed(value):
	for n in nodes :
		n.set_gravity(value)
	$Center.set_gravity(value)
