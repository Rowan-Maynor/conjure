extends Button

var shift_ammount = 65

func _on_pressed() -> void:
	if(self.position.x == 912):
		self.position.x -= shift_ammount
		$"../research_tab_buttons".position.x -= shift_ammount
	else:
		self.position.x += shift_ammount
		$"../research_tab_buttons".position.x += shift_ammount
