extends Control

@export var player_data: Player_Data
@onready var unit_buttons: GridContainer = $main_content_container/VBoxContainer/HBoxContainer/ScrollContainer/unit_buttons

func _ready():
	for key in player_data.recipe_unlocks:
		if(player_data.recipe_unlocks.get(key) == true):
			var unit_button: Button = unit_buttons.get_node(key)
			unit_button.disabled = false
			unit_button.get_child(0).material = null

func _on_pup_pressed() -> void:
	create_unit_panel("pup")


func _on_ember_pressed() -> void:
	create_unit_panel("ember")


func _on_imp_pressed() -> void:
	create_unit_panel("imp")


func _on_guppy_pressed() -> void:
	create_unit_panel("guppy")


func _on_drop_pressed() -> void:
	create_unit_panel("drop")


func _on_gator_pressed() -> void:
	create_unit_panel("gator")


func _on_monkey_pressed() -> void:
	create_unit_panel("monkey")


func _on_pebble_pressed() -> void:
	create_unit_panel("pebble")


func _on_shrub_pressed() -> void:
	create_unit_panel("shrub")


func _on_hound_pressed() -> void:
	create_unit_panel("hound")


func _on_demon_pressed() -> void:
	create_unit_panel("demon")


func _on_skipper_pressed() -> void:
	create_unit_panel("skipper")


func _on_shaman_pressed() -> void:
	create_unit_panel("shaman")


func _on_idol_pressed() -> void:
	create_unit_panel("idol")


func _on_guardian_pressed() -> void:
	create_unit_panel("guardian")


func _on_hell_hound_pressed() -> void:
	create_unit_panel("hell_hound")


func _on_naga_pressed() -> void:
	create_unit_panel("naga")


func _on_great_ape_pressed() -> void:
	create_unit_panel("great_ape")

func create_unit_panel(unit: String):
	var unit_panel: Node = load("res://scenes/ui_components/tome_unit_panel.tscn").instantiate()
	unit_panel.unit_data = load("res://resources/units/" + unit + "/" + unit + ".tres")
	$tome_unit_panel_layer.add_child(unit_panel)
