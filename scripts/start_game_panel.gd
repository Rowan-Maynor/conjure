extends Control

var game_data: Game_Data

func _ready() -> void:
	if(FileAccess.file_exists("user://game_data.tres")):
		game_data = load("user://game_data.tres")
	else:
		var new_game_data: Game_Data = Game_Data.new()
		game_data = new_game_data
	ResourceSaver.save(game_data, "user://game_data.tres")
	
	game_data.skill_page = 1
	game_data.difficulty = "easy"

func _on_start_game_button_pressed() -> void:
	ResourceSaver.save(game_data, "user://game_data.tres")
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_skill_page_option_item_selected(index: int) -> void:
	index += 1
	if(FileAccess.file_exists("user://skill_data_" + str(index) + ".tres")):
		game_data.skill_page = index
	else:
		var new_skill_page: Skill_Data = Skill_Data.new()
		ResourceSaver.save(new_skill_page, "user://skill_data_" + str(index) + ".tres")
		game_data.skill_page = index
