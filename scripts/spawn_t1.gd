extends Button

var t1_units = [
	"res://scenes/units/t1/pig.tscn",
]

func _on_pressed():
	var spawn_areas = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
	var unit = load(t1_units.pick_random()).instantiate()
	var spawn_point = find_open_spawn_point(spawn_areas)
	if(spawn_point == null):
		print("No free space!")
	else:
		unit.position = spawn_point.global_position
		get_tree().get_root().get_node("game").add_child(unit)
		
func find_open_spawn_point(spawn_areas):
	for area in spawn_areas:
		var units = area.has_overlapping_bodies()
		if(units == false):
			return area
	return null
