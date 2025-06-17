extends Node

class_name GraphParser


static var color = Color.PALE_VIOLET_RED
static var strenght_factor = 10
static var created_nodes

static func parse(sim, text):
	created_nodes = Dictionary()
	
	var lines = text.split("\n")
	for line in lines:
		if line == "" or line[0] =="#":
			pass
		elif line[0] == '>':
			color = Color(line.substr(1))
		elif line.contains(">") :
			var parts = line.split('>')
			var nodes = parts[0].split('+')
			
			var target_node = create_node(sim, parts[1])[0]
			for n in nodes:
				var start_node = create_node(sim, n)
				sim.add_force(target_node, start_node[0], start_node[1])
		else:
			create_node(sim, line)

static var next_angle = 0
static var next_dist = 1
static func get_position():
	var p = Vector2(cos(next_angle)*next_dist,sin(next_angle)*next_dist)
	next_angle = next_angle + 60
	next_dist = next_dist + 5
	return p
		
static func create_node(sim, text):
	var node_name = text
	var node_strenght = strenght_factor
	var new_node
	
	# check if ponderation
	if text.contains(":"):
		var args = text.split(":")
		node_name = args[0]
		node_strenght = node_strenght * int(args[1])
	
	# don't create 2 nodes with same name
	if created_nodes.has(node_name):
		new_node = created_nodes[node_name]
	else:
		# create node
		new_node = sim.add_sim_node(get_position())
		new_node.node_name = node_name
		new_node.set_color(color)
	
	# add to dictionnary and return
	created_nodes[node_name] = new_node
	return [new_node, node_strenght]
