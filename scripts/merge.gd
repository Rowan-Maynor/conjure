extends Button

signal merge

func _ready() -> void:
	connect("pressed", _on_pressed)

func _on_pressed():
	emit_signal("merge")
