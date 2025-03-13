extends Node2D

#handles player save data
@export var player_data: Player_data

#handles wave information
@export var wave_data: Wave_data
var wave = 1
var waves_remaining = 0

#handles drag select
var selected = []
var drag_start = Vector2.ZERO
@onready var selection_area = $selection_area
@onready var selection_collision = $selection_area/CollisionShape2D

func _ready():
	player_data = load("res://resources/player/player_data.tres")
	update_player_data_ui()
	
	await get_tree().create_timer(1.0).timeout
	
	player_data.level += 1
	update_player_data_ui()
	save()

func _input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("right_click")):
		for unit in selected:
			unit.reset_target()
			unit.current_command = "move"
			unit.move_position = get_global_mouse_position()
	if(Input.is_action_just_pressed("stop_movement")):
		for unit in selected:
			unit.reset_target()
			unit.current_command = "idle"
			unit.find_new_target()
	if(Input.is_action_just_pressed("hold_position")):
		for unit in selected:
			unit.reset_target()
			unit.current_command = "hold"
			unit.find_new_target()

func _unhandled_input(event: InputEvent) -> void:
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
			
func save():
	ResourceSaver.save(player_data, "res://resources/player/player_data.tres")

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
		if (body.unit_data.control == "player"):
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

func update_player_data_ui():
	$"Main-ui/player_data/level".text = "Level: " + str(int(player_data.level))
	$"Main-ui/player_data/exp".text = "XP: " + str(int(player_data.xp))
	$"Main-ui/player_data/tp".text = "Knowledge: " + str(int(player_data.knowledge))
	
func update_wave_data_ui():
	$"Main-ui/wave_data/wave_value".text = str(wave)
	$"Main-ui/wave_data/waves_remaining_value".text = str(waves_remaining)


#timer that handles the spawning of waves
func _on_wave_delay_timeout() -> void:
	if(waves_remaining > 0):
		spawn_wave()
	else:
		$wave_delay.stop()

func spawn_wave():
	var spawn_areas = get_tree().get_root().get_node("game/enemy_spawn_areas").get_children()
	for spawn_point in spawn_areas:
		var unit = load(wave_data.unit).instantiate()
		unit.unit_data = load("res://resources/waves/wave_" + str(wave) + "/unit_stats.tres").duplicate()
		unit.position = spawn_point.position
		get_tree().get_root().get_node("game").add_child(unit)
	waves_remaining -= 1
	update_wave_data_ui()
