extends Button

func _on_pressed():
	var current_wave = get_tree().get_root().get_node("game").wave
	var wave_data = get_tree().get_root().get_node("game").wave_data
	get_tree().get_root().get_node("game").waves_remaining = wave_data["wave" + str(current_wave)]["wave_count"]
	get_tree().get_root().get_node("game/wave_delay").start()
