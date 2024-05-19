extends Control

@onready var nameLabel = $Panel/NodeName

func set_node(node) :
	nameLabel.Text = node.node_name
