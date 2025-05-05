extends Button

var value: int = int(self.text)

func _on_pressed() -> void:
	get_tree().get_root().get_node("game").bank_deposit(value)
