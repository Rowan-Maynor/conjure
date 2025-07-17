extends Control

@onready var luck_chance_value: Label = $PanelContainer/VBoxContainer/HBoxContainer/tier_value_container/luck_chance_value
var lucky_summon_chance = 0

func _ready():
	luck_chance_value.text = str(lucky_summon_chance) + "%"
