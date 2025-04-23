extends Sprite2D

var new_position: Vector2
var move_distance = 10
var speed = .005
var starting_position: Vector2

func _ready() -> void:
	starting_position.x = self.position.x
	starting_position.y = self.position.y
	get_new_position()
func _physics_process(_delta: float) -> void:
	self.position = self.position.lerp(new_position, speed)

func get_new_position():
	new_position.x = starting_position.x + randi_range(-move_distance, move_distance)
	@warning_ignore("integer_division")
	new_position.y = starting_position.y + randi_range(-(move_distance / 2), (move_distance / 2))
