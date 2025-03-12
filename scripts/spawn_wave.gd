extends Button

func _on_pressed():
	var current_wave = get_tree().get_root().get_node("game").wave
	var new_wave_data = load("res://resources/waves/wave_" + str(current_wave) + "/wave_properties.tres")
	get_tree().get_root().get_node("game").waves_remaining = new_wave_data.wave_count
	get_tree().get_root().get_node("game").wave_data = new_wave_data
	get_tree().get_root().get_node("game/wave_delay").start()
