extends TextureRect

@onready var hover_timer: Timer = $"../mana_hover"

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		self.remove_child(tooltip)

func _on_mana_hover_timeout() -> void:
	var tooltip: Node = load("res://scenes/tooltips/mana_tooltip.tscn").instantiate()
	self.add_child(tooltip)
