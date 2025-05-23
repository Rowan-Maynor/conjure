extends Control

var unit_data: Unit_Data

@onready var attack_value: Label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/attack_value
@onready var attack_speed_value: Label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/attack_speed_value
@onready var range_value: Label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_left/range_value
@onready var critical_value: Label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/critical_value
@onready var speed_value: Label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/speed_value
@onready var element_value: Label = $PanelContainer/HBoxContainer/VBoxContainer/PanelContainer/unit_data_container/unit_data_right/element_value
@onready var unit_sprite: TextureRect = $PanelContainer/HBoxContainer/VBoxContainer/unit_sprite
@onready var unit_type: Label = $PanelContainer/HBoxContainer/VBoxContainer/unit_type
@onready var recipe_container: VBoxContainer = $PanelContainer/HBoxContainer/recipe_container

var recipe_list: Dictionary = {
	"hound": ["imp", "pup"],
	"demon": ["imp", "ember"],
	"skipper": ["gator", "guppy"],
	"shaman": ["gator", "drop"],
	"idol": ["pebble", "monkey"],
	"guardian": ["pebble", "shrub"],
	"hell_hound": ["hound", "demon"],
	"naga": ["skipper", "shaman"],
	"great_ape": ["idol", "guardian"],
}

func _ready():
	attack_value.text = str(unit_data.damage)
	attack_speed_value.text = str(unit_data.attack_speed)
	range_value.text = str(unit_data.attack_range)
	critical_value.text = str(unit_data.critical_chance)
	speed_value.text = str(unit_data.speed)
	element_value.text = str(unit_data.element)
	var unit_type_with_spaces: String = unit_data.type.replace("_", " ")
	unit_type.text = unit_type_with_spaces
	unit_sprite.texture = load("res://assets/sprites/units/" + unit_data.type + "/base.png")
	
	if(recipe_list.has(unit_data.type)):
		var recipe_units: Array = recipe_list.get(unit_data.type)
		for unit in recipe_units:
			var label: Label = Label.new()
			label.text = unit
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			recipe_container.add_child(label)
	else:
		var label: Label = Label.new()
		label.text = "None"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		recipe_container.add_child(label)


func _on_close_panel_button_pressed() -> void:
	self.queue_free()
