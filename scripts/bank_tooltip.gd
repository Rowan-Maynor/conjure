extends Control

@onready var max_mana_label : Label = $PanelContainer/VBoxContainer/body3

func _ready():
	var bank_mana_cap: int = get_tree().get_root().get_node("game").bank_mana_cap
	max_mana_label.text = "Max mana per wave: " + str(bank_mana_cap)
