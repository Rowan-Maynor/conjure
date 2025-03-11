extends PathFollow2D

var speed = 20

func _process(delta: float) -> void:
	progress_ratio += delta * speed * .001
