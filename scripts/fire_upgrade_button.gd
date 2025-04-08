extends Button

var cost = 10

func _on_pressed() -> void:
	get_tree().get_root().get_node("game").spend_mana(cost)
	get_tree().get_root().get_node("game").fire_research_value += .1
	cost += 1
	print(get_tree().get_root().get_node("game").fire_research_value)
