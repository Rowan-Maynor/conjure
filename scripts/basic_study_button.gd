extends Button

@onready var timer = get_tree().get_root().get_node("game/main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer2/basic_study_cooldown")

func _on_pressed() -> void:
	study()


func study():
	get_tree().get_root().get_node("game").spend_mana(1)
	var research_ammount = randi_range(1, 5)
	var message = "Gained " + str(research_ammount) + " research"
	var color = Color.hex(0xe8c078ff)
	get_tree().get_root().get_node("game").gain_research(research_ammount)
	get_tree().get_root().get_node("game").add_status_message(message, color)

func _on_button_down() -> void:
	timer.start()

func _on_button_up() -> void:
	timer.stop()

func _on_basic_study_cooldown_timeout() -> void:
	study()
