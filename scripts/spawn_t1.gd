extends Button

var t1_units = [
	"pup",
	"imp",
	"drop",
	"gator",
	"guppy",
	"ember",
	"shrub",
	"pebble",
	"monkey"
]

signal spend_mana(ammount)

func _on_pressed():
	if(get_tree().get_root().get_node("game").mana >= 5):
		var spawn_areas = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
		var unit = t1_units.pick_random()
		var unit_scene_path = "res://scenes/units/" + unit + ".tscn"
		var instance = load(unit_scene_path).instantiate()
		var unit_data_path = "res://resources/units/" + unit + "/" + unit + ".tres"
		instance.unit_data = load(unit_data_path).duplicate()
		var unit_recipe_path = "res://resources/units/" + unit + "/" + unit + "_recipe.tres"
		instance.recipe_data = load(unit_recipe_path).duplicate()
		var spawn_point = find_open_spawn_point(spawn_areas)
		if(spawn_point == null):
			get_tree().get_root().get_node("game").add_status_message("No free space", Color.hex(0xff3e3eff))
		else:
			instance.position = spawn_point.global_position
			get_tree().get_root().get_node("game").get_node("player_units").add_child(instance)
			get_tree().get_root().get_node("game").add_status_message("Conjured " + instance.unit_data.type)
			emit_signal("spend_mana", 5)
	else:
		get_tree().get_root().get_node("game").add_status_message("Not enough mana", Color.hex(0xff3e3eff))
func find_open_spawn_point(spawn_areas):
	for area in spawn_areas:
		var units = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null
