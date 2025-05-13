extends Button

@onready var hover_timer: Timer = $"../advanced_infusion_hover"

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()

func _on_advanced_infusion_hover_timeout() -> void:
	var tooltip: Node = load("res://scenes/tooltips/basic_infusion_tooltip.tscn").instantiate()
	self.add_child(tooltip)
