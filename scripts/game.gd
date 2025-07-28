extends Node2D

#player save data
@export var player_data: Player_Data

#game data
var game_data: Game_Data

#skill data
var skill_data: Skill_Data

#difficulty data
var difficulty_data: Difficulty_Data

#resource values
var lives: int = 30
var mana: int = 25
var research: int = 0
var kills: int = 0

#bank values
var bank_mana: float = 0.0
var bank_mana_cap: int = 1
var bank_interest: float = 1.10
var auto_deposit: int = 0
var interest_cost: int = 10
var interest_max_upgrades: int = 5

#element research values
var fire_research_value: float = 1.0
var water_research_value: float = 1.0
var earth_research_value: float = 1.0

#wave information
@export var wave_data: Wave_Data
var wave: int
var wave_scale_mult: float = 1.0
var wave_max: int = 1
var waves_remaining: int
var default_wave_time: int = 75
var wave_time: int
var sp_base: int = 10

#drag select
var selected: Array[CharacterBody2D] = []
var drag_start: Vector2 = Vector2.ZERO
@onready var selection_area: Area2D = $selection_area
@onready var selection_collision: CollisionShape2D = $selection_area/CollisionShape2D

#attack_move flag
var attack_move: bool = false

#cursors
var cursor_default: Resource = load("res://assets/ui/cursor_default.png")
var cursor_attack: Resource = load("res://assets/ui/cursor_attack.png")
var cursor_stop: Resource = load("res://assets/ui/cursor_stop.png")
var cursor_hold: Resource = load("res://assets/ui/cursor_hold.png")

#selectors for UI elements
@onready var mana_ui_value: Label = $"main_ui/Main-ui/resource_container/GridContainer/mana_container/mana_value"
@onready var research_ui_value: Label = $"main_ui/Main-ui/resource_container/GridContainer/research_container/research_value"
@onready var wave_ui_value: Label = $"main_ui/Main-ui/wave_data_container/HBoxContainer/VBoxContainer/wave_value"
@onready var time_ui_value: Label = $"main_ui/Main-ui/wave_data_container/HBoxContainer/VBoxContainer/time_value"
@onready var lives_ui_value: Label = $"main_ui/Main-ui/lives_data_container/VBoxContainer/life_value"
@onready var text_box_container: VBoxContainer = $"main_ui/Main-ui/text_box/ScrollContainer/VBoxContainer"
@onready var bank_mana_value: Label = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/bank_data/values/bank_value"
@onready var bank_interest_value: Label = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/bank_data/values/interest_value"
@onready var auto_deposit_value: Label = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/auto_deposit_data/auto_deposit_value"
@onready var bank_projected_value: Label = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/bank_data/values/projected_value"

#button paths
@onready var basic_summon_button: Button = $"main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer/basic_summon_button"
@onready var basic_study_button: Button = $"main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer2/basic_study_button"
@onready var intermediate_study_button: Button = $"main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer2/intermediate_study_button"
@onready var advanced_study_button: Button = $"main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer2/advanced_study_button"
@onready var fire_research_button: Button = $"main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/fire_research_button"
@onready var water_research_button: Button = $"main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/water_research_button"
@onready var earth_research_button: Button = $"main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/earth_research_button"
@onready var bank_deposit_1_button: Button = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/bank_buttons/deposit_1_button"
@onready var bank_deposit_10_button: Button = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/bank_buttons/deposit_10_button"
@onready var bank_withdraw_1_button: Button = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/bank_buttons/withdraw_1_button"
@onready var bank_withdraw_10_button: Button = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/bank_buttons/withdraw_10_button"
@onready var interest_increase_button: Button = $"main_ui/Main-ui/bank_canvas/bank_container/HBoxContainer/VBoxContainer/interest_increase_button"

#general functions
func _ready():
	load_game_data()
	load_player_data()
	load_skill_data()
	load_difficulty_data()
	update_skill_values()
	mana_ui_value.text = str(mana)
	research_ui_value.text = str(research)
	update_mana_buttons()
	update_research_buttons()

func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("print_orphans")):
		print_orphan_nodes()
	if(Input.is_action_just_pressed("toggle_fullscreen")):
		if(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if(Input.is_action_just_pressed("pause")):
		var tome_menu: Node = load("res://scenes/ui_components/tome_controller.tscn").instantiate()
		get_tree().get_root().get_node("game/tome_canvas").add_child(tome_menu)
		get_tree().paused = true
	if(Input.is_action_just_pressed("attack_move")):
		handle_attack_move()
	if(Input.is_action_just_pressed("right_click")):
		if(attack_move == true):
			attack_move = false
			Input.set_custom_mouse_cursor(cursor_default)
			return
		for unit in selected:
			unit.get_node("attack_spawn_delay").stop()
			unit.reset_target()
			unit.current_command = "move"
			var mouse_position: Vector2 = get_global_mouse_position()
			mouse_position.x = clampf(mouse_position.x, 312.0, 648.0)
			mouse_position.y = clampf(mouse_position.y, 104.0, 440.0)
			unit.move_position = mouse_position
			unit.nav.set_target_position(unit.move_position)
	if(Input.is_action_just_pressed("stop_movement")):
		handle_stop_move()
	if(Input.is_action_just_pressed("hold_position")):
		handle_hold_position()
	if(event is InputEventMouseButton && event.button_index == 1 && attack_move == true):
		for unit in selected:
			if(unit.current_command != "focus"):
				unit.get_node("attack_spawn_delay").stop()
				unit.reset_target()
				unit.find_new_target()
				unit.current_command = "attack"
				if(unit.current_target == null):
					var mouse_position: Vector2 = get_global_mouse_position()
					mouse_position.x = clampf(mouse_position.x, 312.0, 648.0)
					mouse_position.y = clampf(mouse_position.y, 104.0, 440.0)
					unit.move_position = mouse_position
					unit.nav.set_target_position(unit.move_position)
		attack_move = false
		Input.set_custom_mouse_cursor(cursor_default)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if(drag_start == Vector2.ZERO && event is InputEventMouseButton 
		&& event.button_index == 1 && event.is_pressed()):
			for body in selected:
				if(body == null):
					continue
				var selection_sprite: Sprite2D = body.get_node("selection_sprite")
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
	var drag_end: Vector2 = get_global_mouse_position()
	var start_x: float = drag_start.x
	var start_y: float = drag_start.y
	var end_x: float = drag_end.x
	var end_y: float = drag_end.y
	
	var line_width: float = 3.0
	var line_color: Color = Color.WHITE
	
	draw_line(Vector2(start_x, start_y), Vector2(end_x, start_y), line_color, line_width)
	draw_line(Vector2(start_x, start_y), Vector2(start_x, end_y), line_color, line_width)
	draw_line(Vector2(end_x, start_y), Vector2(end_x, end_y), line_color, line_width)
	draw_line(Vector2(start_x, end_y), Vector2(end_x, end_y), line_color, line_width)

func _select_units():
	var size: Vector2 = abs(get_global_mouse_position() - drag_start)
	# this will set the minimum size to 1x1 in case people are trying to select 
	# individual units instead of a drag select
	if (size.x == 0 && size.y == 0):
		size.x = 1.0
		size.y = 1.0
	var area_position: Vector2 = _get_rect_start_position()
	
	selection_area.global_position = area_position
	selection_collision.global_position = area_position + size / 2
	selection_collision.shape.size = size
	
	await get_tree().create_timer(.04).timeout
	
	for area in selection_area.get_overlapping_areas():
		var body: CharacterBody2D = area.get_parent()
		if (body.unit_data.control == "player"):
			selected.append(body)
			var selection_sprite: Sprite2D = body.get_node("selection_sprite")
			selection_sprite.visible = true
	
	if(selected.size() != 0):
		if($unit_panel.has_node("UnitDataPanel")):
			update_unit_panel(selected.back())
		else:
			create_unit_panel(selected.back())
	
	if(selected.size() == 0 && $unit_panel.has_node("UnitDataPanel")):
		$unit_panel.get_node("UnitDataPanel").queue_free()

func _get_rect_start_position():
	var new_position: Vector2 = Vector2.ZERO
	var mouse_position: Vector2 = get_global_mouse_position()
	
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
	var panel_ui_scene: Node = load("res://scenes/ui_components/unit_data_panel.tscn").instantiate()
	#this is used to delete the panel when selection removed
	panel_ui_scene.add_to_group("unit_panel")
	update_unit_panel_values(unit, panel_ui_scene)
	
	#atatch panel to canvas
	get_tree().get_root().get_node("game/unit_panel").add_child(panel_ui_scene)
	
	#connect merge button functionality
	$"unit_panel/UnitDataPanel/PanelContainer/VBoxContainer/buttons_container/merge_button".connect("merge", _on_merge)

func update_unit_panel(unit):
	var panel_ui_scene: Control = $unit_panel.get_node("UnitDataPanel")
	update_unit_panel_values(unit, panel_ui_scene)

func update_unit_panel_values(unit, panel_ui_scene):
	#update sprite
	var sprite_node: TextureRect = panel_ui_scene.get_node("PanelContainer/VBoxContainer/unit_sprite")
	var unit_sprite: Resource = load("res://assets/sprites/units/" + unit.unit_data.type + "/base.png")
	sprite_node.texture = unit_sprite
	
	#value selectors
	var attack_value: Label = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/attack_value")
	var attack_speed_value: Label = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/attack_speed_value")
	var range_value: Label = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/range_value")
	var critical_value: Label = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/critical_value")
	var speed_value: Label = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/speed_value")
	var element_value: Label = panel_ui_scene.get_node("PanelContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/element_value")
	var unit_type_value: Label = panel_ui_scene.get_node("PanelContainer/VBoxContainer/unit_type")
	attack_speed_value.text = str(unit.unit_data.attack_speed)
	range_value.text = str(unit.unit_data.attack_range)
	critical_value.text = str(unit.unit_data.critical_chance)
	speed_value.text = str(unit.unit_data.speed)
	element_value.text = str(unit.unit_data.element)
	var unit_type_with_spaces: String = unit.unit_data.type.replace("_", " ")
	unit_type_value.text = unit_type_with_spaces
	attack_value.text = str(calculate_final_damage(unit))

#functions related to game state
func start_game():
	$"main_ui/Main-ui/start_game_button".queue_free()
	wave = 1
	wave_data = load("res://resources/waves/wave_" + str(wave) + "/wave_properties.tres")
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
	var spawn_areas: Array[Node] = get_tree().get_root().get_node("game/enemy_spawn_areas").get_children()
	for spawn_point in spawn_areas:
		var unit: Node = load(wave_data.unit).instantiate()
		unit.unit_data = load("res://resources/waves/wave_" + str(wave) + "/unit_stats.tres").duplicate()
		unit.unit_data.health = calculate_enemy_hp()
		unit.skill_data = skill_data
		unit.position = spawn_point.position
		unit.connect("died", _on_died)
		get_tree().get_root().get_node("game").get_node("enemy_units_nav").add_child(unit)
	waves_remaining -= 1
	if(waves_remaining == 0 && wave % 10 != 0):
		$wave_time.start()

func next_wave():
	wave += 1
	if (wave % 5 == 0):
		wave_scale_mult += .2
		decrease_interest()
	if (wave % 10 == 0):
		bank_mana_cap += 1
	wave_time = default_wave_time
	time_ui_value.text = str(wave_time)
	var wave_path: String = "res://resources/waves/wave_" + str(wave) + "/wave_properties.tres"
	wave_data = load(wave_path)
	waves_remaining = wave_data.wave_count
	spawn_wave()
	$wave_delay.start()

func spawn_boss():
	var spawn_point: Node = get_tree().get_root().get_node("game/enemy_spawn_areas/enemy_spawn_area_3")
	var unit: Node = load(wave_data.unit).instantiate()
	unit.unit_data = load("res://resources/waves/wave_" + str(wave) + "/unit_stats.tres").duplicate()
	var element: String = unit.unit_data.element
	
	#create boss unit
	var boss_unit: Node
	if(element == "fire"):
		boss_unit = load("res://scenes/units/hell_hound.tscn").instantiate()
		boss_unit.unit_data = unit.unit_data
		boss_unit.skill_data = skill_data
		boss_unit.unit_data.type = "hell_hound"
	elif(element == "water"):
		boss_unit = load("res://scenes/units/naga.tscn").instantiate()
		boss_unit.unit_data = unit.unit_data
		boss_unit.skill_data = skill_data
		boss_unit.unit_data.type = "naga"
	elif(element == "earth"):
		boss_unit = load("res://scenes/units/great_ape.tscn").instantiate()
		boss_unit.unit_data = unit.unit_data
		boss_unit.skill_data = skill_data
		boss_unit.unit_data.type = "great_ape"
	
	var wave_scale_mult_final: float = wave_scale_mult
	#Bosses have 5x HP, .2 is for the extra wave 10 mult
	wave_scale_mult_final += 5.2
	boss_unit.unit_data.health = wave * wave_scale_mult_final
	
	boss_unit.position = spawn_point.position
	boss_unit.connect("died", _on_died)
	get_tree().get_root().get_node("game").get_node("enemy_units_nav").add_child(boss_unit)
	#unit was being created but not freed, causing an orphan
	unit.queue_free()
	$wave_time.start()
	$wave_delay.stop()

#functions that handle game timers
func _on_wave_time_timeout() -> void:
	if($enemy_units_nav.get_child_count() == 0):
		if(wave == wave_max):
			var win_screen: Node = load("res://scenes/ui_components/win_screen.tscn").instantiate()
			get_tree().get_root().get_node("game").get_node("main_ui").add_child(win_screen)
			handle_skill_page_unlock()
			return
		else:
			$wave_time.stop()
			if(wave % 5 == 0):
				gain_research(3)
				add_status_message("Gained 3 research", Color.hex(0xe8c078ff))
			if(wave % 10 == 0):
				@warning_ignore("narrowing_conversion")
				var sp_value: int = sp_base * difficulty_data.sp_mult
				gain_sp(sp_value)
				add_status_message("Gained " + str(sp_value) + " SP", Color.hex(0x967bb6ff))
				sp_base += 2
			#handles bank interest
			generate_bank_mana()
			#sets up wait
			wave_time = 10
			add_status_message("Break (10 seconds)", Color.hex(0xafafafff))
			time_ui_value.text = str(wave_time)
			$wait_time.start()
	elif(wave_time > 0):
		wave_time -= 1
		time_ui_value.text = str(wave_time)
	else:
		$wave_time.stop()
		var remaining_enemies: Node = $enemy_units_nav
		lives -= remaining_enemies.get_child_count()
		add_status_message("lives -" + str(remaining_enemies.get_child_count()), Color.hex(0xff3e3eff))
		lives_ui_value.text = str(lives)
		for enemy in remaining_enemies.get_children():
			enemy.die()
		if(lives <= 0):
			var lose_screen: Node = load("res://scenes/ui_components/lose_screen.tscn").instantiate()
			get_tree().get_root().get_node("game").get_node("main_ui").add_child(lose_screen)
			return
		if(lives > 0):
			if(wave == wave_max):
				var win_screen: Node = load("res://scenes/ui_components/win_screen.tscn").instantiate()
				get_tree().get_root().get_node("game").get_node("main_ui").add_child(win_screen)
				return
			else:
				#handles bank interest
				generate_bank_mana()
				#sets up wait
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
	elif(waves_remaining == 0 && wave % 10 == 0):
		spawn_boss()
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
	var selected_copy: Array[CharacterBody2D] = selected.duplicate()
	#takes last unit in selection, pop also removes it from the list itself for later checks
	for i in selected_copy:
		var main_unit: CharacterBody2D = selected_copy.pop_back()
		#list of units found for the recipe
		var input_units: Array[CharacterBody2D] = []
		#keeps track of which recipe was successful
		var recipe_unit: String
		for key in main_unit.recipe_data.list:
			recipe_unit = key
			var merge_possible: bool = true
			var unit_found: bool = false
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
			var unit_scene_path: String = "res://scenes/units/" + recipe_unit + ".tscn"
			var instance: Node = load(unit_scene_path).instantiate()
			var unit_data_path: String = "res://resources/units/" + recipe_unit + "/" + recipe_unit + ".tres"
			instance.unit_data = load(unit_data_path).duplicate()
			var unit_recipe_path: String = "res://resources/units/" + recipe_unit + "/" + recipe_unit + "_recipe.tres"
			instance.recipe_data = load(unit_recipe_path).duplicate()
			instance.skill_data = skill_data
			var spawn_point: Node = find_open_spawn_point()
			if(spawn_point == null):
				add_status_message("No free space", Color.hex(0xff3e3eff))
			else:
				instance.position = spawn_point.global_position
				get_tree().get_root().get_node("game").get_node("player_units_nav").add_child(instance)
				var unit_type_with_spaces: String = instance.unit_data.type.replace("_", " ")
				add_status_message("Conjured " + unit_type_with_spaces)
				check_recipe_unlock(instance.unit_data.type)
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

#input handlers
func handle_attack_move():
	if(attack_move == false):
		attack_move = true
		Input.set_custom_mouse_cursor(cursor_attack)

func handle_hold_position():
	if(attack_move == true):
		attack_move = false
	for unit in selected:
		unit.get_node("attack_spawn_delay").stop()
		unit.reset_target()
		unit.current_command = "hold"
		unit.find_new_target()
	Input.set_custom_mouse_cursor(cursor_hold)
	await get_tree().create_timer(.25).timeout
	Input.set_custom_mouse_cursor(cursor_default)

func handle_stop_move():
	if(attack_move == true):
		attack_move = false
	for unit in selected:
		unit.get_node("attack_spawn_delay").stop()
		unit.reset_target()
		unit.current_command = "idle"
		unit.find_new_target()
	Input.set_custom_mouse_cursor(cursor_stop)
	await get_tree().create_timer(.25).timeout
	Input.set_custom_mouse_cursor(cursor_default)

#saving and loading data
func load_player_data():
	if(ResourceLoader.exists("user://player_data.tres")):
		player_data = load("user://player_data.tres")
	else:
		player_data = load("res://resources/player/player_data.tres")
		save_player_data()

func save_player_data():
	ResourceSaver.save(player_data, "user://player_data.tres")

func load_game_data():
	game_data = load("user://game_data.tres")

func load_skill_data():
	var skill_page_number: int = game_data.skill_page
	skill_data = load("user://skill_data_" + str(skill_page_number) + ".tres")

func update_skill_values():
	calculate_starting_lives()
	calculate_starting_research()
	calculate_starting_mana()
	calculate_bank_cap()

func load_difficulty_data():
	var difficulty: String = game_data.difficulty
	difficulty_data = load("res://resources/difficulties/" + difficulty + ".tres")

#calculation functions
func calculate_final_damage(unit):
	var final_damage: int = unit.unit_data.damage
	
	#apply research damage increase
	if(unit.unit_data.element == "fire"):
		final_damage = floori(unit.unit_data.damage * fire_research_value)
	elif(unit.unit_data.element == "water"):
		final_damage = floori(unit.unit_data.damage * water_research_value)
	elif(unit.unit_data.element == "earth"):
		final_damage = floori(unit.unit_data.damage * earth_research_value)
	
	#apply basic skill page increase
	var basic_skill_mult: float = 1.0
	if(skill_data.skill_current_upgrades.get("damage_basic") > 0):
		for i in range(skill_data.skill_current_upgrades.get("damage_basic")):
			basic_skill_mult += skill_data.skill_values.get("damage_basic")
	final_damage = floor(final_damage * basic_skill_mult)
	
	#return the value
	return final_damage

func calculate_starting_lives():
	var final_lives: int = lives
	
	if(skill_data.skill_current_upgrades.get("lives_basic") > 0):
		for i in range(skill_data.skill_current_upgrades.get("lives_basic")):
			final_lives += skill_data.skill_values.get("lives_basic")
	
	lives = final_lives
	lives_ui_value.text = str(lives)

func calculate_starting_research():
	var final_research: int = research
	
	if(skill_data.skill_current_upgrades["research_basic"] > 0):
		for i in range(skill_data.skill_current_upgrades["research_basic"]):
			final_research += skill_data.skill_values["research_basic"]
			
	if(skill_data.skill_current_upgrades["research_intermediate"] > 0):
		for i in range(skill_data.skill_current_upgrades["research_intermediate"]):
			final_research += skill_data.skill_values["research_intermediate"]
	
	research = final_research
	research_ui_value.text = str(research)

func calculate_starting_mana():
	var final_mana: int = mana
	
	if(skill_data.skill_current_upgrades["starting_mana_basic"] > 0):
		for i in range(skill_data.skill_current_upgrades["starting_mana_basic"]):
			final_mana += skill_data.skill_values["starting_mana_basic"]
			
	if(skill_data.skill_current_upgrades["starting_mana_intermediate"] > 0):
		for i in range(skill_data.skill_current_upgrades["starting_mana_intermediate"]):
			final_mana += skill_data.skill_values["starting_mana_intermediate"]
	
	mana = final_mana
	mana_ui_value.text = str(mana)

func calculate_enemy_hp():
	var wave_scale_mult_final: float = wave_scale_mult
	wave_scale_mult_final += difficulty_data.health_mult
	if(wave % 10 == 0):
		wave_scale_mult_final += .2
	
	return (wave + difficulty_data.health_base) * wave_scale_mult_final

func calculate_bank_cap():
	bank_mana_cap += skill_data.skill_current_upgrades.get("bank_cap_intermediate")

#bank functions
func bank_deposit(value):
	if(value > mana):
		bank_mana += mana
		spend_mana(mana)
		bank_mana_value.text = str(bank_mana)
		bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))
	else:
		bank_mana += value
		spend_mana(value)
		bank_mana_value.text = str(bank_mana)
		bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))

func bank_withdraw(value):
	if(value > bank_mana):
		var remaining_bank: int = floori(bank_mana)
		bank_mana -= remaining_bank
		bank_mana = snapped(bank_mana, .01)
		mana += remaining_bank
		update_mana_buttons()
		mana_ui_value.text = str(mana)
		bank_mana_value.text = str(bank_mana)
		bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))
	else:
		mana += value
		bank_mana -= value
		bank_mana = snapped(bank_mana, .01)
		update_mana_buttons()
		mana_ui_value.text = str(mana)
		bank_mana_value.text = str(bank_mana)
		bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))

func increase_auto_deposit():
	auto_deposit += 1
	auto_deposit_value.text = str(auto_deposit)

func decrease_auto_deposit():
	if(auto_deposit == 0):
		return
	auto_deposit -=1
	auto_deposit_value.text = str(auto_deposit)

func increase_interest():
	if(interest_max_upgrades == 0):
		return
	if(mana < interest_cost):
		return
	var current_interest_cost: int = interest_cost
	interest_max_upgrades -= 1
	bank_interest += 0.01
	interest_cost += 5
	spend_mana(current_interest_cost)
	var bank_interest_snapped: float = snapped((bank_interest - 1.0) * 100, 0.01)
	bank_interest_value.text = str(bank_interest_snapped) + "%"
	bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))
	add_status_message("Interest increased", Color.hex(0xafafafff))

func decrease_interest():
	bank_interest -= 0.01
	var rounded_bank_interest: float = snapped(bank_interest, 0.01)
	bank_interest = rounded_bank_interest
	#need to snap this calculation specifically (floating point issues)
	var bank_interest_percentage = snapped((bank_interest - 1) * 100, 0.01)
	bank_interest_value.text = str(bank_interest_percentage) + "%"
	bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))
	add_status_message("Interest decreased", Color.hex(0xafafafff))

func generate_bank_mana():
	if(auto_deposit > 0):
		if(mana < auto_deposit):
			bank_deposit(mana)
		else:
			bank_deposit(auto_deposit)
	var bank_mana_gained: float = (bank_mana * bank_interest) - bank_mana
	bank_mana_gained = snapped(bank_mana_gained, 0.01)
	if(bank_mana_gained < bank_mana_cap):
		add_status_message("Gained " + str(bank_mana_gained) + " bank mana", Color.hex(0x199fffff))
		bank_mana += bank_mana_gained
		bank_mana_value.text = str(bank_mana)
		bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))
	else:
		add_status_message("Gained " + str(float(bank_mana_cap)) + " bank mana (Max)", Color.hex(0x199fffff))
		bank_mana += bank_mana_cap
		bank_mana_value.text = str(bank_mana)
		bank_projected_value.text = str(snapped(bank_mana * (bank_interest - 1), 0.01))

#helper functions
func add_status_message(message, color = Color.hex(0xffffffff)):
	var label: Label = Label.new()
	label.add_theme_font_size_override("font_size", 16)
	label.set("theme_override_colors/font_color", color)
	#need to add a space because the outline for text gets cut off for some reason
	label.text = " " + message
	label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
	if(text_box_container.get_child_count() != 0):
		var separator: HSeparator = HSeparator.new()
		text_box_container.add_child(separator)
	text_box_container.add_child(label)
	
	if(text_box_container.get_child_count() > 40):
		text_box_container.get_child(0).queue_free()
		text_box_container.get_child(1).queue_free()

func find_open_spawn_point():
	var spawn_areas: Array[Node] = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
	for area in spawn_areas:
		var units: bool = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null

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
		advanced_study_button.disabled = true
		advanced_study_button._on_button_up()
	if(mana < 3):
		intermediate_study_button.disabled = true
		intermediate_study_button._on_button_up()
	if(mana < 1):
		basic_study_button.disabled = true
		basic_study_button._on_button_up()
		bank_deposit_1_button.disabled = true
		bank_deposit_10_button.disabled = true
	if(bank_mana < 1):
		bank_withdraw_1_button.disabled = true
		bank_withdraw_10_button.disabled = true
	if(mana < interest_cost || interest_max_upgrades == 0):
		interest_increase_button.disabled = true
	
	#enable checks
	if(mana >= 5):
		basic_summon_button.disabled = false
		advanced_study_button.disabled = false
	if(mana >= 3):
		intermediate_study_button.disabled = false
	if(mana >= 1):
		basic_study_button.disabled = false
		bank_deposit_1_button.disabled = false
		bank_deposit_10_button.disabled = false
	if(bank_mana >= 1):
		bank_withdraw_1_button.disabled = false
		bank_withdraw_10_button.disabled = false
	if(mana >= interest_cost && interest_max_upgrades > 0):
		interest_increase_button.disabled = false

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

func gain_sp(value: int):
	player_data.sp += value
	save_player_data()

func check_recipe_unlock(type: String):
	if(player_data.recipe_unlocks.get(type) == false):
		player_data.recipe_unlocks.set(type, true)
		create_new_unit_popup(type)
		save_player_data()

func create_new_unit_popup(type: String):
	var canvas_layer = $new_unit_canvas
	var popup: Node = load("res://scenes/ui_components/new_unit_popup.tscn").instantiate()
	var unit_sprite: Node = popup.get_node("PanelContainer/VBoxContainer/unit_sprite")
	unit_sprite.texture = load("res://assets/sprites/units/" + type + "/base.png")
	canvas_layer.add_child(popup)
	popup.modulate = Color(1, 1, 1, 0.0)
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 1.0), 0.5)
	tween.tween_interval(2)
	tween.tween_property(popup, "modulate", Color(1, 1, 1, 0.0), 0.5)
	tween.tween_callback(popup.queue_free)

func handle_skill_page_unlock():
	if(difficulty_data.difficulty == "easy"):
		player_data.skill_page_unlocks["intermediate"] = true
		save_player_data()
	elif(difficulty_data.difficulty == "medium"):
		player_data.skill_page_unlocks["advanced"] = true
		save_player_data()
