extends Control

@onready var total_upgrades: Label = $PanelContainer/VBoxContainer/HBoxContainer/value_container/total_upgrades_value
@onready var total_damage: Label = $PanelContainer/VBoxContainer/HBoxContainer/value_container/total_damage_value
@onready var cost: Label = $PanelContainer/VBoxContainer/HBoxContainer/value_container/cost_value

func _ready():
	update_data()

func update_data():
	var total_damage_value: float = get_tree().get_root().get_node("game").earth_research_value
	var total_upgrades_value: float = (total_damage_value - 1) / .10
	var cost_value: int = get_tree().get_root().get_node("game/main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/earth_research_button").cost
	total_upgrades.text = str(int(total_upgrades_value))
	total_damage.text = str(int(total_damage_value * 100)) + "%"
	if(cost_value < 21):
		cost.text = str(cost_value)
	else:
		cost.text = "MAX"
