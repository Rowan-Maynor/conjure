extends Timer

@onready var clouds = $"../clouds"

func _on_timeout() -> void:
	for cloud in clouds.get_children():
		cloud.get_new_position()
