extends Button

func _ready() -> void:
	connect("pressed", get_tree().get_root().get_node("game").restart_game)

func _on_pressed() -> void:
	self.get_parent().queue_free()
