extends Node2D

#handles player save data
var player_data_path = "user://player_data.json"
var player_data: Dictionary = {}

#handles wave information
var wave = 1
var waves_remaining = 0
var wave_data = {
	"wave1": {"unit": "res://scenes/units/t1/skeleton.tscn",
	"wave_count": 6},
	"wave2": {"unit": "res://scenes/units/t1/pig.tscn",
	"wave_count": 6},
}

#handles drag select
var selected = []
var drag_start = Vector2.ZERO
@onready var selection_area = $selection_area
@onready var selection_collision = $selection_area/CollisionShape2D

func _ready():
	load_player_data(player_data_path)
	update_player_data_ui(player_data)

func _input(event: InputEvent) -> void:
	if(Input.is_action_pressed("clear_data")):
		clear_player_data(player_data_path)
		
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
			for body in selected:
				var selection_sprite = body.get_node("selection_sprite")
				selection_sprite.visible = false
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
	# this will set the minimum size to 1x1 in case people are trying to select 
	# individual units instead of a drag select
	if (size.x == 0 && size.y == 0):
		size.x = 1.0
		size.y = 1.0
	var area_position = _get_rect_start_position()
	
	selection_area.global_position = area_position
	selection_collision.global_position = area_position + size / 2
	selection_collision.shape.size = size
	
	await get_tree().create_timer(.04).timeout
	
	for area in selection_area.get_overlapping_areas():
		var body = area.get_parent()
		if (body.control == "player"):
			selected.append(body)
			var selection_sprite = body.get_node("selection_sprite")
			selection_sprite.visible = true

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


#timer that handles the spawning of waves
func _on_wave_delay_timeout() -> void:
	if(waves_remaining > 0):
		var spawn_areas = get_tree().get_root().get_node("game/enemy_spawn_areas").get_children()
		for spawn_point in spawn_areas:
			var unit = load(wave_data["wave" + str(wave)]["unit"]).instantiate()
			unit.position = spawn_point.global_position
			unit.control = "enemy"
			get_tree().get_root().get_node("game").add_child(unit)
		waves_remaining -= 1
	else:
		$wave_delay.stop()
