extends Control

@export var skill_data: Skill_Data
@export var player_data: Player_Data

var max_sp: int
var available_sp: int
var skill_page = 1

@onready var total_sp_value: Label = $main_panel/VBoxContainer/HBoxContainer/total_sp_value
@onready var available_sp_value: Label = $main_panel/VBoxContainer/HBoxContainer/available_sp_value

func _ready():
	load_skill_data()
	print(skill_data.skill_current_upgrades.get("damage_basic"))

func available_sp_increase(amount: int):
	var current_value = int(available_sp_value.text)
	available_sp_value.text = " " + str(current_value + amount)

func available_sp_decrease(amount: int):
	var current_value = int(available_sp_value.text)
	available_sp_value.text = " " + str(current_value - amount)

func update_data():
	max_sp = player_data.sp
	available_sp = max_sp - skill_data.spent_sp
	total_sp_value.text = " " + str(max_sp)
	available_sp_value.text = " " + str(available_sp)

func _on_skill_page_option_item_selected(index: int) -> void:
	skill_page = index + 1
	$skill_tree_buttons.get_child(0).skill_page = skill_page
	load_skill_data()

func load_skill_data():
	if(FileAccess.file_exists("user://skill_data_" + str(skill_page) + ".tres")):
		skill_data = load("user://skill_data_" + str(skill_page) + ".tres")
	else:
		var new_skill_page: Skill_Data = Skill_Data.new()
		ResourceSaver.save(new_skill_page, "user://skill_data_" + str(skill_page) + ".tres")
		skill_data = load("user://skill_data_" + str(skill_page) + ".tres")
	update_data()
	$skill_tree_buttons.get_child(0).skill_data = load("user://skill_data_" + str(skill_page) + ".tres")
	$skill_tree_buttons.get_child(0).update_data()


func _on_reset_button_pressed() -> void:
	var new_skill_page: Skill_Data = Skill_Data.new()
	ResourceSaver.save(new_skill_page, "user://skill_data_" + str(skill_page) + ".tres")
	skill_data = new_skill_page
	update_data()
	$skill_tree_buttons.get_child(0).skill_data = new_skill_page
	$skill_tree_buttons.get_child(0).update_data()
	print("damage upgrades: ", skill_data.skill_current_upgrades.get("damage_basic"))


func _on_close_button_pressed() -> void:
	self.queue_free()
