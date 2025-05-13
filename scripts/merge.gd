extends Button

signal merge
@onready var hover_timer: Timer = $"../merge_hover"

func _ready() -> void:
	connect("pressed", _on_pressed)

func _on_pressed():
	emit_signal("merge")

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()

func _on_merge_hover_timeout() -> void:
	var tooltip: Node = load("res://scenes/tooltips/merge_tooltip.tscn").instantiate()
	self.add_child(tooltip)
