extends Button

var cost = 10

func _on_pressed() -> void:
	get_tree().get_root().get_node("game").spend_research(cost)
	get_tree().get_root().get_node("game").fire_research_value += .1
	cost += 1
	var damage_percentage = int(get_tree().get_root().get_node("game").fire_research_value * 100)
	var message = "Fire research damage increased to " + str(damage_percentage) + "%"
	var color = Color.hex(0xa778e8ff)
	get_tree().get_root().get_node("game").add_status_message(message, color)
