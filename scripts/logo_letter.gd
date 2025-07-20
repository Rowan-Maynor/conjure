extends TextureRect

var new_position: Vector2
var move_distance: int = 15
var speed: float = .005
var starting_position: Vector2

func _ready():
	new_position.x = self.position.x
	new_position.y = self.position.y
	starting_position.x = self.position.x
	starting_position.y = self.position.y
	_on_letter_movement_timer_timeout()

func _physics_process(_delta: float) -> void:
	self.position = self.position.lerp(new_position, speed)

func _on_letter_movement_timer_timeout() -> void:
	new_position.x = starting_position.x
	new_position.y = starting_position.y - randi_range(0, move_distance)
