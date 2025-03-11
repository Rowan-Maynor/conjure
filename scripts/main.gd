extends Node2D

var player_data_path = "user://player_data.json"
var player_data: Dictionary = {}
var t1_units = [
	"res://scenes/units/t1/pig.tscn",
	"res://scenes/units/t1/skeleton.tscn"
]

func _ready():
	load_player_data(player_data_path)
	update_player_data_ui(player_data)
	
	await get_tree().create_timer(2).timeout
	player_data.level += 1
	player_data.exp += 1000
	player_data.tp += 500
	
	save_player_data(player_data_path, player_data)
	update_player_data_ui(player_data)
	
	print("Done!")

func _input(_event: InputEvent) -> void:
	if(Input.is_action_pressed("clear_data")):
		clear_player_data(player_data_path)
	if(Input.is_action_just_pressed("spawn_t1_unit")):
		var spawn_areas = $player_spawn_areas.get_children()
		var unit = load(t1_units.pick_random()).instantiate()
		var spawn_point = find_open_spawn_point(spawn_areas)
		if(spawn_point == null):
			print("No free space!")
		else:
			unit.position = spawn_point.global_position
			$".".add_child(unit)

func update_player_data_ui(data):
	$"Main-ui/level".text = "Level: " + str(int(data.level))
	$"Main-ui/exp".text = "EXP: " + str(int(data.exp))
	$"Main-ui/tp".text = "TP: " + str(int(data.tp))

func load_player_data(path):
	if not FileAccess.file_exists(path):
		print("No save file found, attempting to create")
		var data = {
			"exp":0.0,
			"level":0.0,
			"name":"Test Name 1",
			"tp":0.0
			}
		save_player_data(path, data)
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json = file.get_as_text()
	var json_object = JSON.new()
	
	json_object.parse(json)
	player_data = json_object.data

func save_player_data(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(data)
		file.store_string(json_text)
	else:
		print("Failed to open or create file")

func clear_player_data(path):
	var data = {
		"exp":0.0,
		"level":0.0,
		"name":"Test Name 1",
		"tp":0.0
		}
	save_player_data(path, data)
	load_player_data(path)
	update_player_data_ui(player_data)

func find_open_spawn_point(spawn_areas):
	for area in spawn_areas:
		var units = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null
