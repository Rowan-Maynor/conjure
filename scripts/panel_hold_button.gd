extends Button

@onready var hover_timer: Timer = $"../hold_hover"

func _on_pressed() -> void:
	get_tree().get_root().get_node("game").handle_hold_position()

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()

func _on_hold_hover_timeout() -> void:
	var tooltip: Node = load("res://scenes/tooltips/hold_tooltip.tscn").instantiate()
	self.add_child(tooltip)
