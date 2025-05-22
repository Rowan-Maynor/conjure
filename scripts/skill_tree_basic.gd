extends Control

@export var skill_data: Skill_Data
@export var player_data: Player_Data

var max_sp: int
var available_sp: int
var skill_page: int = 1

@onready var skill_tree_controller: Node = get_node("/root/MainMenu/skill_page_canvas/skill_tree_controller")

@onready var damage_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/damage_basic/ProgressBar
@onready var health_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/health_basic/ProgressBar
@onready var research_bar: ProgressBar = $main_panel/VBoxContainer/skill_tree_buttons/research_basic/ProgressBar

@onready var upgrade_map: Array = [
	[damage_bar, "damage"],
	[health_bar, "health"],
	[research_bar, "research"],
]

func _ready():
	load_page()
	update_data()
	connect("available_sp_increase", skill_tree_controller.available_sp_increase)
	connect("available_sp_decrease", skill_tree_controller.available_sp_decrease)

func handle_button_press(progress_bar: ProgressBar, upgrade_type: String, cost_change_base: int, cost_change_mult:int):
	var current_cost = skill_data.skill_current_cost.get(upgrade_type + "_basic")
	var current_upgrades = skill_data.skill_current_upgrades.get(upgrade_type + "_basic")
	var max_upgrades = skill_data.skill_max_upgrades.get(upgrade_type + "_basic")
	var spent_sp = skill_data.spent_sp
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if(current_cost == null):
			return
		if(current_cost > available_sp):
			return
		if(progress_bar.value < max_upgrades):
			progress_bar.value += 1
			available_sp -= current_cost
			spent_sp += current_cost
			emit_signal("available_sp_decrease", current_cost)
			current_cost += cost_change_base
			current_cost *= cost_change_mult
			current_upgrades += 1
			skill_data.skill_current_cost.set(upgrade_type + "_basic", current_cost)
			skill_data.skill_current_upgrades.set(upgrade_type + "_basic", current_upgrades)
			skill_data.set("spent_sp", spent_sp)
			save_page()
			print("Upgrades for ", upgrade_type + ":", str(skill_data.skill_current_upgrades.get(upgrade_type + "_basic")))
			print(skill_data.spent_sp)
	elif(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		if(current_cost == null):
			return
		if(progress_bar.value != 0):
			var previous_cost = current_cost - cost_change_base
			previous_cost /= cost_change_mult
			progress_bar.value -= 1
			available_sp += previous_cost
			spent_sp -= previous_cost
			emit_signal("available_sp_increase", previous_cost)
			current_cost -= cost_change_base
			current_cost /= cost_change_mult
			current_upgrades -= 1
			skill_data.skill_current_cost.set(upgrade_type + "_basic", current_cost)
			skill_data.skill_current_upgrades.set(upgrade_type + "_basic", current_upgrades)
			skill_data.set("spent_sp", spent_sp)
			save_page()
			print("Upgrades for ", upgrade_type + ":", str(skill_data.skill_current_upgrades.get(upgrade_type + "_basic")))
			print(skill_data.spent_sp)

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

func update_data():
	max_sp = player_data.sp
	available_sp = max_sp - skill_data.spent_sp
	for upgrade in upgrade_map:
		handle_bar_update(upgrade[0], upgrade[1])

func handle_bar_update(bar: ProgressBar, upgrade_type: String):
	if(skill_data.skill_max_upgrades.get(upgrade_type + "_basic") == null):
		return
	bar.max_value = skill_data.skill_max_upgrades.get(upgrade_type + "_basic")
	print(bar.max_value)
	bar.value = skill_data.skill_current_upgrades.get(upgrade_type + "_basic")
	print(bar.value)

#signals
signal available_sp_increase(ammount: int)
signal available_sp_decrease(ammount: int)

#button_down handlers
func _on_damage_basic_button_down() -> void:
	handle_button_press(damage_bar, "damage", 1, 1)

func _on_health_basic_button_down() -> void:
	handle_button_press(health_bar, "health", 1, 1)

func _on_research_basic_button_down() -> void:
	handle_button_press(research_bar, "research", 0, 1)
