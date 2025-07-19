extends Button

#game data
var game_data: Game_Data

#skill data
var skill_data: Skill_Data

var t1_units: Array[String] = [
	"pup",
	"imp",
	"ember",
	"drop",
	"gator",
	"guppy",
	"shrub",
	"pebble",
	"monkey",
]

var t2_units: Array[String] = [
	"hound",
	"demon",
	"shaman",
	"skipper",
	"idol",
	"guardian"
]

var lucky_summon_chance: int = 0

@onready var cooldown_timer: Timer = get_tree().get_root().get_node("game/main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer/basic_summon_cooldown")

func _ready():
	game_data = load("user://game_data.tres")
	skill_data = load("user://skill_data_" + str(game_data.skill_page) + ".tres")
	calculate_luck()

func _on_pressed():
	summon_unit()

func summon_unit():
	if(get_tree().get_root().get_node("game").mana >= 5):
		var spawn_areas: Array[Node] = get_tree().get_root().get_node("game/player_spawn_areas").get_children()
		var unit: String
		#handles lucky summon chance
		var lucky_summon: int = randi_range(1, 100)
		if(lucky_summon <= lucky_summon_chance):
			unit = t2_units.pick_random()
		else:
			unit = t1_units.pick_random()
		var unit_scene_path: String = "res://scenes/units/" + unit + ".tscn"
		var instance: Node = load(unit_scene_path).instantiate()
		#add relevent data
		var unit_data_path: String = "res://resources/units/" + unit + "/" + unit + ".tres"
		instance.unit_data = load(unit_data_path).duplicate()
		var unit_recipe_path: String = "res://resources/units/" + unit + "/" + unit + "_recipe.tres"
		instance.recipe_data = load(unit_recipe_path).duplicate()
		instance.skill_data = skill_data
		var spawn_point: Area2D = find_open_spawn_point(spawn_areas)
		if(spawn_point == null):
			get_tree().get_root().get_node("game").add_status_message("No free space", Color.hex(0xff3e3eff))
		else:
			instance.position = spawn_point.global_position
			get_tree().get_root().get_node("game").get_node("player_units_nav").add_child(instance)
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
	cooldown_timer.start()

func _on_button_up() -> void:
	cooldown_timer.stop()

func _on_basic_summon_cooldown_timeout() -> void:
	summon_unit()

func _on_mouse_entered() -> void:
	var tooltip: Node = load("res://scenes/tooltips/basic_summon_tooltip.tscn").instantiate()
	tooltip.lucky_summon_chance = lucky_summon_chance
	self.add_child(tooltip)

func _on_mouse_exited() -> void:
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()

func calculate_luck():
	lucky_summon_chance += skill_data.skill_current_upgrades.get("luck_intermediate")
	print(lucky_summon_chance)
