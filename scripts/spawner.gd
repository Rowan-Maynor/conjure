extends Area2D

@export var open: bool = true

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(_body):
	open = false
	
func _on_body_exited(_body):
	open = true
