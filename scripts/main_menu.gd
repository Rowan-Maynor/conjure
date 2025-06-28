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
	if($start_game_canvas.get_child_count() == 0):
		var start_game_panel: Node = load("res://scenes/ui_components/start_game_panel.tscn").instantiate()
		$start_game_canvas.add_child(start_game_panel)
	else:
		$start_game_canvas.get_child(0).queue_free()

func _on_skills_button_pressed() -> void:
	if($start_game_canvas.get_child_count() != 0):
		$start_game_canvas.get_child(0).queue_free()
	var skill_page: Node = load("res://scenes/ui_components/skill_tree_controller.tscn").instantiate()
	$skill_page_canvas.add_child(skill_page)
