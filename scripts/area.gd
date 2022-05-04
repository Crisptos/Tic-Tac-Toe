extends Area2D

onready var x = preload("res://assets/X.png")
onready var o = preload("res://assets/O.png")

signal pressed()

var selected = true
var state = "_"

func play_x():
	$X_O.set_texture(x)
	state = "X"
	
func play_o():
	$X_O.set_texture(o)
	state = "O"

func clear():
	$X_O.set_texture(null)
	state = '_'

func _on_POS_input_event(viewport, event, shape_idx):
	if(event is InputEventMouseButton):
		if(event.button_index == BUTTON_LEFT):
			emit_signal("pressed", self)
