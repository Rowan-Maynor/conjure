extends Control

@onready var unit_sprite = $PanelContainer/VBoxContainer/unit_sprite

func change_unit_sprite(unit):
	unit_sprite.texture = load("res://assets/sprites/units/" + unit + "/base.png")
