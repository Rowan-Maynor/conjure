extends Button

var cost: int = 1
var max_upgrades: int = 20
@onready var cooldown_timer: Timer = get_tree().get_root().get_node("game/main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/fire_research_cooldown")
@onready var hover_timer: Timer = get_tree().get_root().get_node("game/main_ui/Main-ui/research_tab_buttons/HBoxContainer/VBoxContainer/fire_research_hover")

func _on_pressed() -> void:
	upgrade()
	if(self.get_children()):
		self.get_child(0).update_data()

func upgrade():
	if(max_upgrades == 0):
		return
	if(get_tree().get_root().get_node("game").research < cost):
		return
	
	get_tree().get_root().get_node("game").fire_research_value += .1
	get_tree().get_root().get_node("game").spend_research(cost)
	cost += 1
	self.text = "\n" + str(cost)
	var damage_percentage: int = int(get_tree().get_root().get_node("game").fire_research_value * 100)
	var message: String = "Fire research damage increased to " + str(damage_percentage) + "%"
	var color: Color = Color.hex(0xa778e8ff)
	get_tree().get_root().get_node("game").add_status_message(message, color)
	max_upgrades -= 1
	
	#call button update after cost increase and upgrade deduction
	get_tree().get_root().get_node("game").update_research_buttons()
	
	if(get_tree().get_root().get_node("game/unit_panel").has_node("UnitDataPanel")):
		var unit: CharacterBody2D = get_tree().get_root().get_node("game").selected.back()
		get_tree().get_root().get_node("game").update_unit_panel(unit)

func _on_fire_research_cooldown_timeout() -> void:
	upgrade()

func _on_button_down() -> void:
	cooldown_timer.start()


func _on_button_up() -> void:
	cooldown_timer.stop()

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		self.remove_child(tooltip)

func _on_fire_research_hover_timeout() -> void:
	var tooltip: Node = load("res://scenes/tooltips/fire_research_tooltip.tscn").instantiate()
	self.add_child(tooltip)
