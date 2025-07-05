extends Control

@export var skill_data: Skill_Data
@export var player_data: Player_Data

var max_sp: int
var available_sp: int
var skill_page: int = 1

@onready var skill_tree_controller: Node = get_node("/root/MainMenu/skill_page_canvas/skill_tree_controller")

#upgrade button progress bar selectors
@onready var damage_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/damage_intermediate/ProgressBar
@onready var bank_cap_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/bank_cap_intermediate/ProgressBar
@onready var research_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/research_intermediate/ProgressBar
@onready var critical_chance_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/critical_chance_intermediate/ProgressBar
@onready var critical_damage_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/critical_damage_intermediate/ProgressBar
@onready var starting_mana_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/starting_mana_intermediate/ProgressBar
@onready var bank_research_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/bank_research_intermediate/ProgressBar

#upgrade unlock progress bar selectors
@onready var critical_chance_unlock_bar:ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/critical_chance_intermediate_unlock
@onready var critical_damage_unlock_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/critical_damage_intermediate_unlock
@onready var starting_mana_unlock_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/starting_mana_intermediate_unlock

#upgrade button selectors
@onready var critical_chance_button: Button = $main_panel/VBoxContainer/skill_tree_buttons/critical_chance_intermediate
@onready var critical_damage_button: Button = $main_panel/VBoxContainer/skill_tree_buttons/critical_damage_intermediate
@onready var starting_mana_button: Button = $main_panel/VBoxContainer/skill_tree_buttons/starting_mana_intermediate
@onready var bank_cap_button: Button = $main_panel/VBoxContainer/skill_tree_buttons/bank_cap_intermediate
@onready var bank_research_button: Button = $main_panel/VBoxContainer/skill_tree_buttons/bank_research_intermediate
@onready var damage_button: Button = $main_panel/VBoxContainer/skill_tree_buttons/damage_intermediate
@onready var research_button: Button = $main_panel/VBoxContainer/skill_tree_buttons/research_intermediate

@onready var upgrade_map: Array = [
	#if any changes are made to cost scaling, update skill_data.gd to next version
	#this will wipe all players' saved pages and update them to the new version
	
	#progress bar, upgrade type, upgrade unlocks, cost_change_base, cost_change_mult
	[damage_bar, "damage", "critical_chance", 1, 1],
	[bank_cap_bar, "bank_cap", null, 0, 1],
	[research_bar, "research", "starting_mana", 0, 1],
	[bank_research_bar, "bank_research", null, 1, 1],
	[critical_chance_bar, "critical_chance", "critical_damage", 1, 1],
	[critical_damage_bar, "critical_damage", null, 1, 1],
	[starting_mana_bar, "starting_mana", null, 10, 1],
]

@onready var upgrade_unlock_map: Array = [
	#progress bar, previous upgrade required, current upgrade button
	[critical_chance_unlock_bar, "damage", critical_chance_button],
	[critical_damage_unlock_bar, "critical_chance", critical_damage_button],
	[starting_mana_unlock_bar, "research", starting_mana_button],
]

func _ready():
	load_player_data()
	load_page()
	update_data()
	connect("available_sp_increase", skill_tree_controller.available_sp_increase)
	connect("available_sp_decrease", skill_tree_controller.available_sp_decrease)

func handle_button_press(current_upgrade_map: Array):
	var current_cost = skill_data.skill_current_cost.get(current_upgrade_map[1] + "_intermediate")
	var current_upgrades = skill_data.skill_current_upgrades.get(current_upgrade_map[1] + "_intermediate")
	var max_upgrades = skill_data.skill_max_upgrades.get(current_upgrade_map[1] + "_intermediate")
	var spent_sp = skill_data.spent_sp
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if(current_cost == null):
			return
		if(current_cost > available_sp):
			return
		if(current_upgrade_map[0].value < max_upgrades):
			available_sp -= current_cost
			spent_sp += current_cost
			emit_signal("available_sp_decrease", current_cost)
			current_cost += current_upgrade_map[3]
			current_cost *= current_upgrade_map[4]
			current_upgrades += 1
			skill_data.skill_current_cost.set(current_upgrade_map[1] + "_intermediate", current_cost)
			skill_data.skill_current_upgrades.set(current_upgrade_map[1] + "_intermediate", current_upgrades)
			skill_data.set("spent_sp", spent_sp)
			save_page()
			update_data()
	elif(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		if(current_cost == null):
			return
		if(current_upgrade_map[2] != null):
			if(skill_data.skill_current_upgrades.get(current_upgrade_map[2] + "_intermediate") == null):
				return
			if(skill_data.skill_current_upgrades.get(current_upgrade_map[2] + "_intermediate") > 0):
				return
		if(current_upgrade_map[0].value != 0):
			var previous_cost = current_cost - current_upgrade_map[3]
			previous_cost /= current_upgrade_map[4]
			available_sp += previous_cost
			spent_sp -= previous_cost
			emit_signal("available_sp_increase", previous_cost)
			current_cost -= current_upgrade_map[3]
			current_cost /= current_upgrade_map[4]
			current_upgrades -= 1
			skill_data.skill_current_cost.set(current_upgrade_map[1] + "_intermediate", current_cost)
			skill_data.skill_current_upgrades.set(current_upgrade_map[1] + "_intermediate", current_upgrades)
			skill_data.set("spent_sp", spent_sp)
			save_page()
			update_data()

func save_page():
	ResourceSaver.save(skill_data, "user://skill_data_" + str(skill_page) + ".tres")

func load_page():
	if(FileAccess.file_exists("user://skill_data_" + str(skill_page) + ".tres")):
		skill_data = load("user://skill_data_" + str(skill_page) + ".tres")
	else:
		var new_skill_page: Skill_Data = Skill_Data.new()
		ResourceSaver.save(new_skill_page, "user://skill_data_" + str(skill_page) + ".tres")
		skill_data = load("user://skill_data_" + str(skill_page) + ".tres")
	update_data()

func load_player_data():
	if(FileAccess.file_exists("user://player_data.tres")):
		player_data = load("user://player_data.tres")
	else:
		var new_player_data: Player_Data = Player_Data.new()
		player_data = new_player_data
		ResourceSaver.save(player_data, "user://player_data.tres")

func update_data():
	max_sp = player_data.sp
	available_sp = max_sp - skill_data.spent_sp
	for upgrade in upgrade_map:
		handle_bar_update(upgrade[0], upgrade[1])
	for unlock in upgrade_unlock_map:
		handle_unlock_bar_update(unlock[0], unlock[1])
		handle_unlock_button_update(unlock[0], unlock[1], unlock[2])

func handle_bar_update(bar: ProgressBar, upgrade_type: String):
	if(skill_data.skill_max_upgrades.get(upgrade_type + "_intermediate") == null):
		return
	bar.max_value = skill_data.skill_max_upgrades.get(upgrade_type + "_intermediate")
	bar.value = skill_data.skill_current_upgrades.get(upgrade_type + "_intermediate")

func handle_unlock_bar_update(bar: ProgressBar, previous_upgrade: String):
	if(skill_data.skill_max_upgrades.get(previous_upgrade + "_intermediate") == null):
		return
	bar.max_value = skill_data.skill_max_upgrades.get(previous_upgrade + "_intermediate")
	bar.value = skill_data.skill_current_upgrades.get(previous_upgrade + "_intermediate")

func handle_unlock_button_update(bar: ProgressBar, previous_upgrade: String, upgrade_button: Button):
	if(skill_data.skill_max_upgrades.get(previous_upgrade + "_intermediate") == null):
		return
	if(bar.value == bar.max_value):
		upgrade_button.disabled = false
		upgrade_button.get_node("TextureRect").z_index = 1
	else:
		upgrade_button.disabled = true
		upgrade_button.get_node("TextureRect").z_index = 0

#signals
signal available_sp_increase(ammount: int)
signal available_sp_decrease(ammount: int)

#button_down handlers
func _on_damage_intermediate_button_down() -> void:
	handle_button_press(upgrade_map[0])
	if(damage_button.get_child(2)):
		var tooltip: Node = damage_button.get_child(2)
		tooltip.update_values("damage_intermediate")

func _on_bank_cap_intermediate_button_down() -> void:
	handle_button_press(upgrade_map[1])
	if(bank_cap_button.get_child(2)):
		var tooltip: Node = bank_cap_button.get_child(2)
		tooltip.update_values("bank_cap_intermediate")

func _on_research_intermediate_button_down() -> void:
	handle_button_press(upgrade_map[2])
	if(research_button.get_child(2)):
		var tooltip: Node = research_button.get_child(2)
		tooltip.update_values("research_intermediate")

func _on_bank_research_intermediate_button_down() -> void:
	handle_button_press(upgrade_map[3])
	if(bank_research_button.get_child(2)):
		var tooltip: Node = bank_research_button.get_child(2)
		tooltip.update_values("bank_research_intermediate")

func _on_critical_chance_intermediate_button_down() -> void:
	handle_button_press(upgrade_map[4])
	if(critical_chance_button.get_child(2)):
		var tooltip: Node = critical_chance_button.get_child(2)
		tooltip.update_values("critical_chance_intermediate")

func _on_critical_damage_intermediate_button_down() -> void:
	handle_button_press(upgrade_map[5])
	if(critical_damage_button.get_child(2)):
		var tooltip: Node = critical_damage_button.get_child(2)
		tooltip.update_values("critical_damage_intermediate")

func _on_starting_mana_intermediate_button_down() -> void:
	handle_button_press(upgrade_map[6])
	if(starting_mana_button.get_child(2)):
		var tooltip: Node = starting_mana_button.get_child(2)
		tooltip.update_values("starting_mana_intermediate")

#tooltip functions
func _on_bank_cap_intermediate_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_bank_cap_skill_tooltip.tscn").instantiate()
	tooltip.skill_data = skill_data
	bank_cap_button.add_child(tooltip)

func _on_bank_cap_intermediate_mouse_exited() -> void:
	if(bank_cap_button.get_child(2)):
		var tooltip: Node = bank_cap_button.get_child(2)
		tooltip.queue_free()

func _on_damage_intermediate_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_damage_skill_tooltip.tscn").instantiate()
	tooltip.skill_data = skill_data
	damage_button.add_child(tooltip)

func _on_damage_intermediate_mouse_exited() -> void:
	if(damage_button.get_child(2)):
		var tooltip: Node = damage_button.get_child(2)
		tooltip.queue_free()

func _on_critical_chance_intermediate_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_critical_chance_skill_tooltip.tscn").instantiate()
	tooltip.skill_data = skill_data
	critical_chance_button.add_child(tooltip)

func _on_critical_chance_intermediate_mouse_exited() -> void:
	if(critical_chance_button.get_child(2)):
		var tooltip: Node = critical_chance_button.get_child(2)
		tooltip.queue_free()

func _on_bank_research_intermediate_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_bank_research_skill_tooltip.tscn").instantiate()
	tooltip.skill_data = skill_data
	bank_research_button.add_child(tooltip)

func _on_bank_research_intermediate_mouse_exited() -> void:
	if(bank_research_button.get_child(2)):
		var tooltip: Node = bank_research_button.get_child(2)
		tooltip.queue_free()

func _on_research_intermediate_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_research_skill_tooltip.tscn").instantiate()
	tooltip.skill_data = skill_data
	research_button.add_child(tooltip)

func _on_research_intermediate_mouse_exited() -> void:
	if(research_button.get_child(2)):
		var tooltip: Node = research_button.get_child(2)
		tooltip.queue_free()

func _on_starting_mana_intermediate_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_mana_skill_tooltip.tscn").instantiate()
	tooltip.skill_data = skill_data
	starting_mana_button.add_child(tooltip)

func _on_starting_mana_intermediate_mouse_exited() -> void:
	if(starting_mana_button.get_child(2)):
		var tooltip: Node = starting_mana_button.get_child(2)
		tooltip.queue_free()

func _on_critical_damage_intermediate_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_critical_damage_skill_tooltip.tscn").instantiate()
	tooltip.skill_data = skill_data
	critical_damage_button.add_child(tooltip)

func _on_critical_damage_intermediate_mouse_exited() -> void:
	if(critical_damage_button.get_child(2)):
		var tooltip: Node = critical_damage_button.get_child(2)
		tooltip.queue_free()
