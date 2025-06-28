extends TextureRect

func _on_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/health_tooltip.tscn").instantiate()
	self.add_child(tooltip)

func _on_mouse_exited() -> void:
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()
