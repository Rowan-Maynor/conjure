extends Button

signal merge

func _ready() -> void:
	connect("pressed", _on_pressed)

func _on_pressed():
	emit_signal("merge")

func _on_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/merge_tooltip.tscn").instantiate()
	self.add_child(tooltip)

func _on_mouse_exited() -> void:
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()
