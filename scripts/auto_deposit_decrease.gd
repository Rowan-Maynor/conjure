extends Button


func _on_pressed() -> void:
	get_tree().get_root().get_node("game").decrease_auto_deposit()
