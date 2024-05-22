extends Control

@onready var nameLabel = $Panel/VBoxContainer/NodeName
@onready var forcesLabel = $Panel/VBoxContainer/NodeForces
@onready var miscLabel = $GeneralContainer/MiscDisplay

var current_node

func _process(_delta):
	if not current_node :
		$sel_dot.visible = false
	else :
		$sel_dot.visible = true
		$sel_dot.global_position = current_node.global_position

func set_node(node) :
	current_node = node
	nameLabel.text = node.node_name
	$Panel/VBoxContainer/size_slide.value = node.size * 10
	$Panel/VBoxContainer/gravity_slide.value = node.get_gravity()
	$Panel/VBoxContainer/node_color.color = node.color
	$Panel/VBoxContainer/fixed_button.button_pressed = node.fixed
	forcesLabel.text = ""
	for nf in node.forces :
		forcesLabel.text += " - %s-%s : %s\n" % [nf.targetA.node_name, nf.targetB.node_name, str(nf.force)]

func _on_size_slide_value_changed(value):
	if not current_node :
		return
	current_node.set_size(value / 10)

func display_pause(is_paused) :
	if is_paused :
		miscLabel.text = "PAUSE"
	else :
		miscLabel.text = "ON"

func _on_node_name_text_changed(new_text):
	if not current_node :
		return
	current_node.node_name = new_text.strip_edges()


func _on_damp_slide_value_changed(value):
	if not current_node :
		return
	current_node.set_gravity(value)


func _on_node_color_color_changed(color):
	if not current_node :
		return
	current_node.set_color(color)


func _on_fixed_button_toggled(toggled_on):
	if not current_node :
		return
	current_node.set_fixed(toggled_on)
