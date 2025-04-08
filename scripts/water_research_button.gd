extends Button

var cost = 10
var max_upgrades = 10
@onready var timer = get_tree().get_root().get_node("game/main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/water_research_cooldown")

func _on_pressed() -> void:
	upgrade()

func upgrade():
	if(max_upgrades == 0):
		return
	if(get_tree().get_root().get_node("game").research < cost):
		return
	
	get_tree().get_root().get_node("game").water_research_value += .1
	cost += 1
	var damage_percentage = int(get_tree().get_root().get_node("game").water_research_value * 100)
	var message = "Water research damage increased to " + str(damage_percentage) + "%"
	var color = Color.hex(0xa778e8ff)
	get_tree().get_root().get_node("game").add_status_message(message, color)
	max_upgrades -= 1
	
	#spend research must come after upgrade decrement for UI to properly disable button
	get_tree().get_root().get_node("game").spend_research(cost)
	
	if(get_tree().get_root().get_node("game/unit_panel").has_node("UnitDataPanel")):
		var unit = get_tree().get_root().get_node("game").selected.back()
		get_tree().get_root().get_node("game").update_unit_panel(unit)

func _on_water_research_cooldown_timeout() -> void:
	upgrade()

func _on_button_down() -> void:
	timer.start()


func _on_button_up() -> void:
	timer.stop()
