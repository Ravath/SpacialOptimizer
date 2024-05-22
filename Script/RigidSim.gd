extends Node2D


@onready var info_panel = $CameraTrack/Camera2D/Info

var current_node_hover = null

var text_writing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	info_panel.display_pause($NodeCollection.pause_simulation)
	pass

func _process(_delta) :
	if not text_writing:
		if Input.is_action_just_pressed("create_node") :
			var mousePos = get_global_mouse_position()
			$NodeCollection.add_sim_node(mousePos)
		if Input.is_action_just_pressed("delete_node") and current_node_hover :
			if current_node_hover != $NodeCollection/Center :
				$NodeCollection.delete_node(current_node_hover)
				current_node_hover = null
		if Input.is_action_just_pressed("set_fixed") and current_node_hover :
			current_node_hover.set_fixed(!current_node_hover.fixed)
		if Input.is_action_just_pressed("add_amitie") and current_node_hover and info_panel.current_node :
			$NodeCollection.add_force(current_node_hover, info_panel.current_node, 1)
		if Input.is_action_just_pressed("add_ennemitie") and current_node_hover and info_panel.current_node :
			$NodeCollection.add_force(current_node_hover, info_panel.current_node, -1)
		if Input.is_action_just_pressed("pause") :
			$NodeCollection.swap_pause()
			info_panel.display_pause($NodeCollection.pause_simulation)
		if Input.is_action_just_pressed("duplicate_node") and current_node_hover :
			$NodeCollection.duplicate_node(current_node_hover)
		if Input.is_action_just_pressed("split_node") and current_node_hover :
			$NodeCollection.split_node(current_node_hover)
		if Input.is_action_just_pressed("rand_gen") :
			$NodeCollection.create_test_nodes()
		if Input.is_action_just_pressed("reset") :
			$NodeCollection.reset()
		if Input.is_action_just_pressed("save") :
			$SaveFileDialog.visible = true
		if Input.is_action_just_pressed("load") :
			$LoadFileDialog.visible = true
		

func _physics_process(_delta):
	# Get the node the mouse is currently hovering
	var space = get_world_2d().direct_space_state
	var mousePos = get_global_mouse_position()
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position= mousePos
	parameters.collide_with_areas = false
	parameters.collide_with_bodies = true
	parameters.collision_mask = 1
	# Check if there is a collision at the mouse position
	var res = space.intersect_point(parameters, 1)
	if res :
		# And get corresponding Node
		current_node_hover = res[0]["collider"]
		if not current_node_hover is RigidNode :
			current_node_hover = null
	else:
		current_node_hover = null
	
	# update hovering display
	if not current_node_hover:
		$hovering_dot.visible = false
	else :
		$hovering_dot.visible = true
		$hovering_dot.global_position = current_node_hover.global_position
		$hovering_dot/Panel/Label.text = current_node_hover.node_name
		$hovering_dot/Panel/Label.scale = Vector2(
			1.0/$CameraTrack/Camera2D.zoom.x,
			1.0/$CameraTrack/Camera2D.zoom.y)

func save_simulation(savefile) :
	print("save")
	var save_game = FileAccess.open(savefile, FileAccess.WRITE)
	var save_nodes = []
	var save_forces = []
	var save_forces_center = []
	for n in $NodeCollection.nodes :
		#var save_dict = n.save()
		save_nodes.append(n.save())
	for f in $NodeCollection.forces :
		#var save_dict = n.save()
		save_forces.append(f.save())
	for f in $NodeCollection.center_forces :
		#var save_dict = n.save()
		save_forces_center.append(f.save())

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(JSON.stringify($NodeCollection/Center.save()))
	save_game.store_line(JSON.stringify(save_nodes))
	save_game.store_line(JSON.stringify(save_forces))
	save_game.store_line(JSON.stringify(save_forces_center))

func load_simulation(filename) :
	print("load")
	if not FileAccess.file_exists(filename):
		return # Error! We don't have a save to load.
	
	# Clean data
	$NodeCollection.reset()
	
	# Get save file
	var save_game = FileAccess.open(filename, FileAccess.READ)
	var json = JSON.new()

	# set Center Node
	var json_string = save_game.get_line()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	else :
		$NodeCollection/Center.load(json.get_data())

	# Get nodes
	json_string = save_game.get_line()
	parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	else :
		for nd in json.get_data() :
			var new_object  = $NodeCollection.new_node()
			$NodeCollection.nodes.append(new_object)
			new_object.load(nd)

	# Get forces
	json_string = save_game.get_line()
	parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	else :
		for nd in json.get_data() :
			var targetA = $NodeCollection.get_by_node_name(nd["targetA"])
			var targetB = $NodeCollection.get_by_node_name(nd["targetB"])
			$NodeCollection.forces.append(RigidForce.new(targetA, targetB, nd["force"]))

	# Get center forces
	json_string = save_game.get_line()
	parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	else :
		for nd in json.get_data() :
			var targetA = $NodeCollection.get_by_node_name(nd["targetA"])
			var targetB = $NodeCollection.get_by_node_name(nd["targetB"])
			$NodeCollection.center_forces.append(RigidForce.new(targetA, targetB, nd["force"]))


# called when a text input gui gains focus
func _on_node_name_focus_entered():
	# prevent key strokes to be used as shortcuts
	text_writing = true

# called when a text input gui loses focus
func _on_node_name_focus_exited():
	# can use shortcuts again
	text_writing = false

func _on_save_file_dialog_file_selected(path):
	save_simulation(path)

func _on_load_file_dialog_file_selected(path):
	load_simulation(path)
