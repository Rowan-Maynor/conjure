extends Node2D

#handles player save data
@export var player_data: Player_Data

var lives = 30
var mana = 25
var research = 0
var kills = 0

#handles wave information
@export var wave_data: Wave_Data
var wave
var wave_max = 3
var waves_remaining
var wave_time

#handles drag select
var selected = []
var drag_start = Vector2.ZERO
@onready var selection_area = $selection_area
@onready var selection_collision = $selection_area/CollisionShape2D

func _ready():
	player_data = load("res://resources/player/player_data.tres")
	update_player_data_ui()
	$"Main-ui/buttons/merge".connect("merge", _on_merge)
	$"Main-ui/buttons/spawn_t1".connect("spend_mana", _on_mana_spent)
	$"Main-ui/resources/mana".text = "Mana: " + str(mana)
	
	await get_tree().create_timer(1.0).timeout
	
	player_data.level += 1
	update_player_data_ui()
	save()

func _input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("right_click")):
		for unit in selected:
			unit.get_node("attack_spawn_delay").stop()
			unit.reset_target()
			unit.current_command = "move"
			unit.move_position = get_global_mouse_position()
	if(Input.is_action_just_pressed("stop_movement")):
		for unit in selected:
			unit.get_node("attack_spawn_delay").stop()
			unit.reset_target()
			unit.current_command = "idle"
			unit.find_new_target()
	if(Input.is_action_just_pressed("hold_position")):
		for unit in selected:
			unit.get_node("attack_spawn_delay").stop()
			unit.reset_target()
			unit.current_command = "hold"
			unit.find_new_target()

func _unhandled_input(event: InputEvent) -> void:
	if(drag_start == Vector2.ZERO && event is InputEventMouseButton 
		&& event.button_index == 1 && event.is_pressed()):
			for body in selected:
				if(body == null):
					continue
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

func _on_wave_delay_timeout() -> void:
	if(waves_remaining > 0):
		spawn_wave()
	else:
		$wave_delay.stop()

func spawn_wave():
	$"Main-ui/wave_data/wave_value".text = str(wave)
	$"Main-ui/wave_data/status_value".text = "Spawning"
	var spawn_areas = get_tree().get_root().get_node("game/enemy_spawn_areas").get_children()
	for spawn_point in spawn_areas:
		var unit = load(wave_data.unit).instantiate()
		unit.unit_data = load("res://resources/waves/wave_" + str(wave) + "/unit_stats.tres").duplicate()
		unit.position = spawn_point.position
		unit.connect("died", _on_died)
		get_tree().get_root().get_node("game").get_node("enemy_units").add_child(unit)
	waves_remaining -= 1
	if(waves_remaining == 0):
		$"Main-ui/wave_data/status_value".text = "Defend"
		$wave_time.start()

func _on_merge():
	if(selected == []):
		return
	var selected_copy = selected.duplicate()
	#takes last unit in selection, pop also removes it from the list itself for later checks
	for i in selected_copy:
		var main_unit = selected_copy.pop_back()
		#list of units found for the recipe
		var input_units = []
		#keeps track of which recipe was successful
		var recipe_unit
		for key in main_unit.recipe_data.list:
			recipe_unit = key
			var merge_possible = true
			var unit_found = false
			for unit in main_unit.recipe_data.list[key]:
				for selected_unit in selected_copy:
					#loops through all selected units to see if any of them match the currently
					#needed unit for the recipe
					if(selected_unit.unit_data.type == unit && !input_units.has(selected_unit)):
						unit_found = true
						input_units.push_back(selected_unit)
						break
				if(unit_found == false):
					#if the unit is not found, show that merge isnt possible and break
					merge_possible = false
					break
				else:
					#resets unit_found for next iteration in case recipe needs more than 1 unit
					unit_found = false
			if(merge_possible == true):
				#break here if merge is possible to show that you have found a successful recipe
				break
			else:
				#if the current recipe is not valid, reset your input units and check the next key
				input_units = []
		# input units will be present on successful recipe
		if(input_units != []):
			var unit_scene_path = "res://scenes/units/" + recipe_unit + ".tscn"
			var instance = load(unit_scene_path).instantiate()
			var unit_data_path = "res://resources/units/" + recipe_unit + "/" + recipe_unit + ".tres"
			instance.unit_data = load(unit_data_path).duplicate()
			var unit_recipe_path = "res://resources/units/" + recipe_unit + "/" + recipe_unit + "_recipe.tres"
			instance.recipe_data = load(unit_recipe_path).duplicate()
			var spawn_point = find_open_spawn_point()
			if(spawn_point == null):
				print("No free space!")
			else:
				instance.position = spawn_point.global_position
				get_tree().get_root().get_node("game").get_node("player_units").add_child(instance)
				#merged unit is now spawned, free the others
				selected.pop_at(selected.find(main_unit))
				main_unit.queue_free()
				for unit in input_units:
					selected.pop_at(selected.find(unit))
					unit.queue_free()
				return

func find_open_spawn_point():
	var spawn_areas = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
	for area in spawn_areas:
		var units = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null

func start_game():
	$"Main-ui/buttons/start_game".disabled = true
	wave_data = load("res://resources/waves/wave_1/wave_properties.tres")
	wave = 1
	waves_remaining = wave_data.wave_count
	wave_time = 75
	$"Main-ui/wave_data/time_value".text = str(wave_time)
	$"Main-ui/lives_data/lives_value".text = str(lives)
	spawn_wave()
	$wave_delay.start()

func _on_wave_time_timeout() -> void:
	if($enemy_units.get_child_count() == 0):
		$wave_time.stop()
		wave_time = 10
		$"Main-ui/wave_data/status_value".text = "Break"
		$"Main-ui/wave_data/time_value".text = str(wave_time)
		$wait_time.start()
	elif(wave_time > 0):
		wave_time -= 1
		$"Main-ui/wave_data/time_value".text = str(wave_time)
	else:
		$wave_time.stop()
		var remaining_enemies = $enemy_units
		lives -= remaining_enemies.get_child_count()
		$"Main-ui/lives_data/lives_value".text = str(lives)
		for enemy in remaining_enemies.get_children():
			enemy.die()
		if(lives <= 0):
			$"Main-ui/wave_data/status_value".text = "YOU LOSE BUSTER"
		if(lives > 0):
			wave_time = 10
			$"Main-ui/wave_data/status_value".text = "Break"
			$wait_time.start()


func _on_wait_time_timeout() -> void:
	if(wave_time > 0):
		wave_time -= 1
		$"Main-ui/wave_data/time_value".text = str(wave_time)
	else:
		$wait_time.stop()
		next_wave()

func next_wave():
	wave += 1
	if(wave > wave_max):
		$"Main-ui/wave_data/status_value".text = "YOU WIN BUSTER"
		$"Main-ui/buttons/start_game".disabled = false
		return
	wave_time = 75
	$"Main-ui/wave_data/time_value".text = str(wave_time)
	var wave_path = "res://resources/waves/wave_" + str(wave) + "/wave_properties.tres"
	wave_data = load(wave_path)
	waves_remaining = wave_data.wave_count
	spawn_wave()
	$wave_delay.start()

func _on_mana_spent(ammount):
	mana -= ammount
	$"Main-ui/resources/mana".text = "Mana: " + str(mana)

func _on_died(_body):
	if($wave_time.is_stopped() == true):
		return
	else:
		kills += 1
		if(kills % 5 == 0):
			mana += 1
			$"Main-ui/resources/mana".text = "Mana: " + str(mana)
