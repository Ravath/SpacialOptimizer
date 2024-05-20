extends Node2D


@onready var info_panel = $CameraTrack/Camera2D/Info

var current_node_hover = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$NodeCollection.create_test_nodes()
	pass

func _process(_delta) :
	if Input.is_action_just_pressed("create_node") :
		var mousePos = get_global_mouse_position()
		$NodeCollection.add_sim_node(mousePos)
	if Input.is_action_just_pressed("delete_node") and current_node_hover :
		$NodeCollection.delete_node(current_node_hover)
	if Input.is_action_just_pressed("set_fixed") and current_node_hover :
		current_node_hover.set_fixed(!current_node_hover.fixed)
	if Input.is_action_just_pressed("add_amitie") and current_node_hover and info_panel.current_node :
		$NodeCollection.add_force(current_node_hover, info_panel.current_node, 1)
	if Input.is_action_just_pressed("add_ennemitie") and current_node_hover and info_panel.current_node :
		$NodeCollection.add_force(current_node_hover, info_panel.current_node, -1)
	if Input.is_action_just_pressed("pause") :
		$NodeCollection.swap_pause()
		

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
