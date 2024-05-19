extends Node2D


@onready var info_panel = $CameraTrack/Camera2D/Info

# Called when the node enters the scene tree for the first time.
func _ready():
	$NodeCollection.create_test_nodes()
	pass
