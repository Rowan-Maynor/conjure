extends Button


func _on_pressed() -> void:
	get_tree().get_root().get_node("game").handle_attack_move()
