extends Button

@onready var cooldown_timer: Timer = get_tree().get_root().get_node("game/main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer2/intermediate_study_cooldown")
@onready var hover_timer: Timer = get_tree().get_root().get_node("game/main_ui/Main-ui/mana_tab_buttons/HBoxContainer/VBoxContainer2/intermediate_study_hover")

func _on_pressed() -> void:
	study()

func study():
	get_tree().get_root().get_node("game").spend_mana(3)
	var research_ammount: int = randi_range(3, 18)
	var message: String = "Gained " + str(research_ammount) + " research"
	var color: Color = Color.hex(0xe8c078ff)
	get_tree().get_root().get_node("game").gain_research(research_ammount)
	get_tree().get_root().get_node("game").add_status_message(message, color)

func _on_button_down() -> void:
	cooldown_timer.start()

func _on_button_up() -> void:
	cooldown_timer.stop()

func _on_basic_study_cooldown_timeout() -> void:
	study()

func _on_mouse_entered() -> void:
	hover_timer.start()

func _on_mouse_exited() -> void:
	hover_timer.stop()
	if(self.get_children()):
		var tooltip: Node = self.get_child(0)
		tooltip.queue_free()

func _on_intermediate_study_hover_timeout() -> void:
	var tooltip: Node = load("res://scenes/tooltips/intermediate_study_tooltip.tscn").instantiate()
	self.add_child(tooltip)
