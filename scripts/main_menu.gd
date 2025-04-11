extends Control

func _input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("toggle_fullscreen")):
		if(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
