extends Control

@onready var nameLabel = $Panel/NodeName

var current_node

func set_node(node) :
	current_node = node
	nameLabel.text = node.node_name
	$Panel/size_slide.value = node.size * 10

func _on_size_slide_value_changed(value):
	if not current_node :
		return
	current_node.set_size(value / 10)
	pass # Replace with function body.
