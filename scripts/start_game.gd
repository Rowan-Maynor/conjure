extends Button

func _on_pressed():
	get_tree().get_root().get_node("game").start_game()
