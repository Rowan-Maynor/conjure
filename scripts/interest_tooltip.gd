extends Control

@onready var cost_value_label: Label = $PanelContainer/VBoxContainer/HBoxContainer/value_container/cost_value
@onready var total_upgrades_value_label: Label = $PanelContainer/VBoxContainer/HBoxContainer/value_container/total_upgrades_value

func _ready():
	update_data()


func update_data():
	var game_node: Node = get_tree().get_root().get_node("game")
	var cost: int = game_node.interest_cost
	#max upgrades is 5, so if the player buys 2, subtracting 5 will give -2
	#absi(-2) = 2 which is the number of upgrades
	var total_upgrades:int = absi(game_node.interest_max_upgrades - 5)
	cost_value_label.text = str(cost)
	total_upgrades_value_label.text = str(total_upgrades)
