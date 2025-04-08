extends Button



func _on_pressed() -> void:
	get_tree().get_root().get_node("game").spend_mana(1)
	var research_ammount = randi_range(1, 5)
	var message = "Gained " + str(research_ammount) + " research"
	var color = Color.hex(0xe8c078ff)
	get_tree().get_root().get_node("game").gain_research(research_ammount)
	get_tree().get_root().get_node("game").add_status_message(message, color)
