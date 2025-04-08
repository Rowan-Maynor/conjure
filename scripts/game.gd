extends Node2D

#player save data
@export var player_data: Player_Data

#resource values
var lives = 30
var mana = 25
var research = 0
var kills = 0

#element research values
var fire_research_value = 1.0
var water_research_value = 1.0
var earth_research_value = 1.0

#wave information
@export var wave_data: Wave_Data
var wave
var wave_max = 10
var waves_remaining
var default_wave_time = 75
var wave_time

#drag select
var selected = []
var drag_start = Vector2.ZERO
@onready var selection_area = $selection_area
@onready var selection_collision = $selection_area/CollisionShape2D

#selectors for UI elements
@onready var mana_ui_value = $"main_ui/Main-ui/resource_container/GridContainer/mana_container/mana_value"
@onready var research_ui_value = $"main_ui/Main-ui/resource_container/GridContainer/research_container/research_value"
@onready var wave_ui_value = $"main_ui/Main-ui/wave_data_container/HBoxContainer/VBoxContainer/wave_value"
@onready var time_ui_value = $"main_ui/Main-ui/wave_data_container/HBoxContainer/VBoxContainer/time_value"
@onready var lives_ui_value = $"main_ui/Main-ui/lives_data_container/VBoxContainer/life_value"
@onready var text_box_container = $"main_ui/Main-ui/text_box/ScrollContainer/VBoxContainer"

#button paths
@onready var basic_summon_button = $"main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer/basic_summon_button"
@onready var basic_study_button = $"main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer2/basic_study_button"
@onready var fire_research_button = $"main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/fire_research_button"
@onready var water_research_button = $"main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/water_research_button"
@onready var earth_research_button = $"main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/earth_research_button"

#general functions
func _ready():
	player_data = load("res://resources/player/player_data.tres")
	mana_ui_value.text = str(mana)
	research_ui_value.text = str(research)
	update_mana_buttons()
	update_research_buttons()
	save()

func _input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("toggle_fullscreen")):
		if(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if(Input.is_action_just_pressed("pause")):
		var pause_menu = load("res://scenes/pause_menu.tscn").instantiate()
		get_tree().get_root().get_node("game/pause_menu_canvas").add_child(pause_menu)
		get_tree().paused = true
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

func _process(_delta):
	queue_redraw()

#functions related to unit selection
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
	
	if(selected.size() != 0):
		if($unit_panel.has_node("UnitDataPanel")):
			update_unit_panel(selected.back())
		else:
			create_unit_panel(selected.back())
	
	if(selected.size() == 0 && $unit_panel.has_node("UnitDataPanel")):
		$unit_panel.get_node("UnitDataPanel").queue_free()

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

#functions related to unit panel
func create_unit_panel(unit):
	var panel_ui_scene = load("res://scenes/ui_components/unit_data_panel.tscn").instantiate()
	#this is used to delete the panel when selection removed
	panel_ui_scene.add_to_group("unit_panel")
	update_unit_panel_values(unit, panel_ui_scene)
	
	#atatch panel to canvas
	get_tree().get_root().get_node("game/unit_panel").add_child(panel_ui_scene)
	
	#connect merge button functionality
	$"unit_panel/UnitDataPanel/PanelContainer/VBoxContainer/buttons_container/merge_button".connect("merge", _on_merge)

func update_unit_panel(unit):
	var panel_ui_scene = $unit_panel.get_node("UnitDataPanel")
	update_unit_panel_values(unit, panel_ui_scene)

func update_unit_panel_values(unit, panel_ui_scene):
	#update sprite
	var sprite_node = panel_ui_scene.get_node("PanelContainer/VBoxContainer/unit_sprite")
	var unit_sprite = load("res://assets/sprites/units/" + unit.unit_data.type + "/base.png")
	sprite_node.texture = unit_sprite
	
	#value selectors
	var attack_value = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/attack_value")
	var attack_speed_value = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/attack_speed_value")
	var range_value = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/range_value")
	var critical_value = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/critical_value")
	var speed_value = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/speed_value")
	var element_value = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/element_value")
	var unit_type_value = panel_ui_scene.get_node("PanelContainer/VBoxContainer/unit_type")
	attack_speed_value.text = str(unit.unit_data.attack_speed)
	range_value.text = str(unit.unit_data.attack_range)
	critical_value.text = "0"
	speed_value.text = str(unit.unit_data.speed)
	element_value.text = str(unit.unit_data.element)
	unit_type_value.text = unit.unit_data.type
	attack_value.text = str(calculate_final_damage(unit))

#functions related to game state
func start_game():
	$"main_ui/Main-ui/start_game_button".queue_free()
	wave_data = load("res://resources/waves/wave_1/wave_properties.tres")
	wave = 1
	waves_remaining = wave_data.wave_count
	wave_time = default_wave_time
	time_ui_value.text = str(wave_time)
	lives_ui_value.text = str(lives)
	spawn_wave()
	$wave_delay.start()

func restart_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

#functions related to spawning waves
func spawn_wave():
	if(waves_remaining == wave_data.wave_count):
		add_status_message("Wave " + str(wave) + " starting", Color.hex(0xafafafff))
	wave_ui_value.text = str(wave)
	var spawn_areas = get_tree().get_root().get_node("game/enemy_spawn_areas").get_children()
	for spawn_point in spawn_areas:
		var unit = load(wave_data.unit).instantiate()
		unit.unit_data = load("res://resources/waves/wave_" + str(wave) + "/unit_stats.tres").duplicate()
		unit.position = spawn_point.position
		unit.connect("died", _on_died)
		get_tree().get_root().get_node("game").get_node("enemy_units").add_child(unit)
	waves_remaining -= 1
	if(waves_remaining == 0):
		$wave_time.start()

func next_wave():
	wave += 1
	wave_time = default_wave_time
	time_ui_value.text = str(wave_time)
	var wave_path = "res://resources/waves/wave_" + str(wave) + "/wave_properties.tres"
	wave_data = load(wave_path)
	waves_remaining = wave_data.wave_count
	spawn_wave()
	$wave_delay.start()

#functions that handle game timers
func _on_wave_time_timeout() -> void:
	if($enemy_units.get_child_count() == 0):
		if(wave == wave_max):
			var win_screen = load("res://scenes/win_screen.tscn").instantiate()
			get_tree().get_root().get_node("game").get_node("main_ui").add_child(win_screen)
			return
		else:
			$wave_time.stop()
			wave_time = 10
			add_status_message("Break (10 seconds)", Color.hex(0xafafafff))
			time_ui_value.text = str(wave_time)
			$wait_time.start()
	elif(wave_time > 0):
		wave_time -= 1
		time_ui_value.text = str(wave_time)
	else:
		$wave_time.stop()
		var remaining_enemies = $enemy_units
		lives -= remaining_enemies.get_child_count()
		add_status_message("lives -" + str(remaining_enemies.get_child_count()), Color.hex(0xff3e3eff))
		lives_ui_value.text = str(lives)
		for enemy in remaining_enemies.get_children():
			enemy.die()
		if(lives <= 0):
			var lose_screen = load("res://scenes/lose_screen.tscn").instantiate()
			get_tree().get_root().get_node("game").get_node("main_ui").add_child(lose_screen)
			return
		if(lives > 0):
			if(wave == wave_max):
				var win_screen = load("res://scenes/win_screen.tscn").instantiate()
				get_tree().get_root().get_node("game").get_node("main_ui").add_child(win_screen)
				return
			else:
				wave_time = 10
				add_status_message("Break (10 seconds)", Color.hex(0xafafafff))
				$wait_time.start()

func _on_wait_time_timeout() -> void:
	if(wave_time > 0):
		wave_time -= 1
		time_ui_value.text = str(wave_time)
	else:
		$wait_time.stop()
		next_wave()

func _on_wave_delay_timeout() -> void:
	if(waves_remaining > 0):
		spawn_wave()
	else:
		$wave_delay.stop()

#functions that handle signals from other nodes
func spend_mana(ammount):
	mana -= ammount
	mana_ui_value.text = str(mana)
	update_mana_buttons()

func _on_died(_body):
	if($wave_time.is_stopped() == true):
		return
	else:
		kills += 1
		if(kills % 5 == 0):
			mana += 1
			mana_ui_value.text = str(mana)
			update_mana_buttons()

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
				add_status_message("No free space", Color.hex(0xff3e3eff))
			else:
				instance.position = spawn_point.global_position
				get_tree().get_root().get_node("game").get_node("player_units").add_child(instance)
				add_status_message("Conjured " + instance.unit_data.type)
				#merged unit is now spawned, free the others
				selected.pop_at(selected.find(main_unit))
				main_unit.queue_free()
				for unit in input_units:
					selected.pop_at(selected.find(unit))
					unit.queue_free()
				if(selected.size() > 0):
					update_unit_panel(selected[selected.size() - 1])
				else:
					$unit_panel.get_node("UnitDataPanel").queue_free()
				return

#helper functions
func add_status_message(message, color = Color.hex(0xffffffff)):
	var label = Label.new()
	label.add_theme_font_size_override("font_size", 16)
	label.set("theme_override_colors/font_color", color)
	label.text = message
	label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
	var separator = HSeparator.new()
	if(text_box_container.get_child_count() != 0):
		text_box_container.add_child(separator)
	text_box_container.add_child(label)
	
	if(text_box_container.get_child_count() > 20):
		text_box_container.get_child(0).queue_free()
		text_box_container.get_child(1).queue_free()

func find_open_spawn_point():
	var spawn_areas = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
	for area in spawn_areas:
		var units = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null

func save():
	ResourceSaver.save(player_data, "res://resources/player/player_data.tres")

func gain_research(ammount):
	research += ammount
	research_ui_value.text = str(research)
	update_research_buttons()

func spend_research(ammount):
	research -= ammount
	research_ui_value.text = str(research)
	update_research_buttons()

func update_mana_buttons():
	#disable checks
	if(mana < 5):
		basic_summon_button.disabled = true
		basic_summon_button._on_button_up()
	if(mana < 1):
		basic_study_button.disabled = true
		basic_study_button._on_button_up()
	
	#enable checks
	if(mana >= 5):
		basic_summon_button.disabled = false
	if(mana >= 1):
		basic_study_button.disabled = false

func update_research_buttons():
	#disable checks
	if(research < fire_research_button.cost || fire_research_button.max_upgrades == 0):
		fire_research_button.disabled = true
		fire_research_button._on_button_up()
	if(research < water_research_button.cost || water_research_button.max_upgrades == 0):
		water_research_button.disabled = true
		water_research_button._on_button_up()
	if(research < earth_research_button.cost || earth_research_button.max_upgrades == 0):
		earth_research_button.disabled = true
		earth_research_button._on_button_up()

	#enable checks
	if(research >= fire_research_button.cost && fire_research_button.max_upgrades > 0):
		fire_research_button.disabled = false
	if(research >= water_research_button.cost && water_research_button.max_upgrades > 0):
		water_research_button.disabled = false
	if(research >= earth_research_button.cost && earth_research_button.max_upgrades > 0):
		earth_research_button.disabled = false

func calculate_final_damage(unit):
	var final_damage = unit.unit_data.damage
	
	#apply research damage increase
	if(unit.unit_data.element == "fire"):
		final_damage = floori(unit.unit_data.damage * fire_research_value)
	elif(unit.unit_data.element == "water"):
		final_damage = floori(unit.unit_data.damage * water_research_value)
	elif(unit.unit_data.element == "earth"):
		final_damage = floori(unit.unit_data.damage * earth_research_value)
	
	#return the value
	return final_damage
