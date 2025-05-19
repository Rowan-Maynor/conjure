extends Control

@onready var tome_content: Node = $tome_content

func _on_close_tome_button_pressed() -> void:
	self.queue_free()


func _on_units_pressed() -> void:
	open_tome_section("units")


func _on_mechanics_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	open_tome_section("options")

func open_tome_section(section: String):
	var tome_section_scene: Node
	
	if(section == "units"):
		tome_section_scene = load("res://scenes/ui_components/tome_units.tscn").instantiate()
	elif(section == "options"):
		tome_section_scene = load("res://scenes/ui_components/tome_options.tscn").instantiate()
	
	tome_content.get_child(0).queue_free()
	tome_content.add_child(tome_section_scene)
