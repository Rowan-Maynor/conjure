extends Button

var t1_units: Array[String] = [
	#"pup",
	#"imp",
	"drop",
	"gator",
	"guppy",
	#"ember",
	#"shrub",
	#"pebble",
	#"monkey"
]

@onready var timer: Timer = get_tree().get_root().get_node("game/main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer/basic_summon_cooldown")

func _on_pressed():
	summon_unit()

func summon_unit():
	if(get_tree().get_root().get_node("game").mana >= 5):
		var spawn_areas: Array[Node] = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
		var unit: String = t1_units.pick_random()
		var unit_scene_path: String = "res://scenes/units/" + unit + ".tscn"
		var instance: Node = load(unit_scene_path).instantiate()
		var unit_data_path: String = "res://resources/units/" + unit + "/" + unit + ".tres"
		instance.unit_data = load(unit_data_path).duplicate()
		var unit_recipe_path: String = "res://resources/units/" + unit + "/" + unit + "_recipe.tres"
		instance.recipe_data = load(unit_recipe_path).duplicate()
		var spawn_point: Area2D = find_open_spawn_point(spawn_areas)
		if(spawn_point == null):
			get_tree().get_root().get_node("game").add_status_message("No free space", Color.hex(0xff3e3eff))
		else:
			instance.position = spawn_point.global_position
			get_tree().get_root().get_node("game").get_node("player_units").add_child(instance)
			var unit_type_with_spaces: String = instance.unit_data.type.replace("_", " ")
			get_tree().get_root().get_node("game").add_status_message("Conjured " + unit_type_with_spaces)
			get_tree().get_root().get_node("game").spend_mana(5)
	else:
		get_tree().get_root().get_node("game").add_status_message("Not enough mana", Color.hex(0xff3e3eff))

func find_open_spawn_point(spawn_areas):
	for area in spawn_areas:
		var units: bool = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null

func _on_button_down() -> void:
	timer.start()

func _on_button_up() -> void:
	timer.stop()

func _on_basic_summon_cooldown_timeout() -> void:
	summon_unit()
