extends Button

@onready var hover_timer: Timer = $"../interest_hover"

func _on_pressed() -> void:
	get_tree().get_root().get_node("game").increase_interest()
	#updates tooltip if open
	if(self.get_children()):
		self.get_child(0).update_data()

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()

func _on_interest_hover_timeout() -> void:
	var tooltip: Node = load("res://scenes/tooltips/interest_tooltip.tscn").instantiate()
	self.add_child(tooltip)
