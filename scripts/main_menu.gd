extends Control

var player_data: Player_Data

func _ready():
	load_player_data()
	save_player_data()

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

func load_player_data():
	if(ResourceLoader.exists("user://player_data.tres")):
		player_data = load("user://player_data.tres")
	else:
		player_data = Player_Data.new()
	check_player_data_version()

func check_player_data_version():
	var test_player_data: Player_Data = Player_Data.new()
	if(player_data.version == test_player_data.version):
		return
	else:
		update_player_data_version(test_player_data)
		player_data = test_player_data

func update_player_data_version(new_player_data):
	if(player_data.sp):
		new_player_data.sp = player_data.sp
	if(player_data.recipe_unlocks):
		for key in player_data.recipe_unlocks:
			new_player_data.recipe_unlocks[key] = player_data.recipe_unlocks[key]
	if(player_data.skill_page_unlocks):
		for key in player_data.skill_page_unlocks:
			new_player_data.skill_page_unlocks[key] = player_data.skill_page_unlocks[key]

func save_player_data():
	ResourceSaver.save(player_data, "user://player_data.tres")
