extends Control

@export var skill_data: Skill_Data

#selectors
@onready var skill_per_value: Label = $PanelContainer/VBoxContainer/HBoxContainer/skill_value_container/skill_per_value
@onready var skill_total_value: Label = $PanelContainer/VBoxContainer/HBoxContainer/skill_value_container/skill_total_value
@onready var skill_cost_value: Label = $PanelContainer/VBoxContainer/HBoxContainer/skill_value_container/skill_cost_value
@onready var skill_total_increase_value: Label = $PanelContainer/VBoxContainer/HBoxContainer/skill_value_container/skill_total_increase_value

func _ready():
	update_values("critical_chance_intermediate")

func update_values(skill: String):
	skill_per_value.text = str(skill_data.skill_values.get(skill)) + "%"
	skill_total_value.text = str(skill_data.skill_current_upgrades.get(skill))
	if(skill_data.skill_current_upgrades.get(skill) == skill_data.skill_max_upgrades.get(skill)):
		skill_cost_value.text = "MAX"
	else:
		skill_cost_value.text = str(skill_data.skill_current_cost.get(skill))
	var total_increase: float = skill_data.skill_values.get(skill) * skill_data.skill_current_upgrades.get(skill)
	skill_total_increase_value.text = str(total_increase) + "%"
