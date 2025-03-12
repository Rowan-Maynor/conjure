extends Button

var t1_units = [
	"human",
]

var unit_scene_path = {
	"human": "res://scenes/units/t1/human.tscn"
}

var unit_data_path = {
	"human": "res://resources/units/human.tres"
}

func _on_pressed():
	var spawn_areas = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
	var unit = t1_units.pick_random()
	var instance = load(unit_scene_path[unit]).instantiate()
	instance.unit_data = load(unit_data_path[unit])
	var spawn_point = find_open_spawn_point(spawn_areas)
	if(spawn_point == null):
		print("No free space!")
	else:
		instance.position = spawn_point.global_position
		get_tree().get_root().get_node("game").add_child(instance)
		
func find_open_spawn_point(spawn_areas):
	for area in spawn_areas:
		var units = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null
