extends Control

func _input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("pause")):
		resume()
		get_viewport().set_input_as_handled()

func resume():
	get_tree().paused = false
	self.queue_free()

func _on_resume_button_pressed() -> void:
	resume()


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()


func _on_restart_game_button_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
