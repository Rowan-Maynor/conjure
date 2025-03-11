extends Node2D

var player_data_path = "user://player_data.json"
var player_data: Dictionary = {}
var t1_units = [
	"res://scenes/units/t1/pig.tscn",
	"res://scenes/units/t1/skeleton.tscn"
]

#handles drag select
var selected = []
var drag_start = Vector2.ZERO
@onready var selection_area = $selection_area
@onready var selection_collision = $selection_area/CollisionShape2D

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

func _input(event: InputEvent) -> void:
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
			
	if(Input.is_action_just_released("right_click")):
		for unit in selected:
			unit.click_position = get_global_mouse_position()
			unit.current_command = "move"
			
	if(Input.is_action_just_pressed("stop_movement")):
		for unit in selected:
			unit.click_position = unit.position
			unit.current_command = "stop"
			
	if(drag_start == Vector2.ZERO && event is InputEventMouseButton 
		&& event.button_index == 1 && event.is_pressed()):
			selected = []
			drag_start = get_global_mouse_position()
	elif(drag_start != Vector2.ZERO && event is InputEventMouseButton 
		&& event.button_index == 1):
			_select_units()
			drag_start = Vector2.ZERO

func _process(_delta):
	queue_redraw()

func _draw():
	if (drag_start == Vector2.ZERO):
		return
	var drag_end = get_global_mouse_position()
	var start_x = drag_start.x
	var start_y = drag_start.y
	var end_x = drag_end.x
	var end_y = drag_end.y
	
	var line_width = 3.0
	var line_color = Color.WHITE
	
	draw_line(Vector2(start_x, start_y), Vector2(end_x, start_y), line_color, line_width)
	draw_line(Vector2(start_x, start_y), Vector2(start_x, end_y), line_color, line_width)
	draw_line(Vector2(end_x, start_y), Vector2(end_x, end_y), line_color, line_width)
	draw_line(Vector2(start_x, end_y), Vector2(end_x, end_y), line_color, line_width)

func _select_units():
	var size = abs(get_global_mouse_position() - drag_start)
	var area_position = _get_rect_start_position()
	
	selection_area.global_position = area_position
	selection_collision.global_position = area_position + size / 2
	selection_collision.shape.size = size
	
	await get_tree().create_timer(.04).timeout
	
	for body in selection_area.get_overlapping_bodies():
		if (body.control == "player"):
			selected.append(body)

func _get_rect_start_position():
	var new_position = Vector2.ZERO
	var mouse_position = get_global_mouse_position()
	
	if (drag_start.x < mouse_position.x):
		new_position.x = drag_start.x
	else:
		new_position.x = mouse_position.x
	
	if (drag_start.y < mouse_position.y):
		new_position.y = drag_start.y
	else:
		new_position.y = mouse_position.y
	
	return new_position

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
