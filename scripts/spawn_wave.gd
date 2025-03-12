extends Button

var t1_units = [
	"res://scenes/units/t1/pig.tscn",
	"res://scenes/units/t1/skeleton.tscn"
]

func _on_pressed():
	var spawn_areas = get_tree().get_root().get_node("game/enemy_spawn_areas").get_children()
	for spawn_point in spawn_areas:
		var unit = load(t1_units.pick_random()).instantiate()
		unit.position = spawn_point.global_position
		unit.control = "enemy"
		get_tree().get_root().get_node("game").add_child(unit)
