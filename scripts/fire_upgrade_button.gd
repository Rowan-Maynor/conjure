extends Button

var cost = 10
@onready var timer = get_tree().get_root().get_node("game/CanvasLayer/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/fire_research_cooldown")

func _on_pressed() -> void:
	upgrade()

func upgrade():
	get_tree().get_root().get_node("game").spend_research(cost)
	get_tree().get_root().get_node("game").fire_research_value += .1
	cost += 1
	var damage_percentage = int(get_tree().get_root().get_node("game").fire_research_value * 100)
	var message = "Fire research damage increased to " + str(damage_percentage) + "%"
	var color = Color.hex(0xa778e8ff)
	get_tree().get_root().get_node("game").add_status_message(message, color)

func _on_fire_research_cooldown_timeout() -> void:
	upgrade()

func _on_button_down() -> void:
	timer.start()


func _on_button_up() -> void:
	timer.stop()
