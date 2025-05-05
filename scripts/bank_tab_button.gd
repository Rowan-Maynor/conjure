extends Button

var shift_ammount: int = 230
var self_closed_position: Vector2
var self_open_position: Vector2
var tab_closed_position: Vector2
var tab_open_position: Vector2
var speed: float = .2
var is_open: bool = false
@onready var bank_container: PanelContainer  = $"../bank_container"
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	self_closed_position.x = -20
	self_closed_position.y = 180
	self_open_position.x = self_closed_position.x + shift_ammount
	self_open_position.y = 180
	tab_closed_position.x = -251
	tab_closed_position.y = 92
	tab_open_position.x = tab_closed_position.x + shift_ammount
	tab_open_position.y = 92

func _physics_process(_delta: float) -> void:
	if(is_open == true):
		self.position = self.position.lerp(self_open_position, speed)
		bank_container.position = bank_container.position.lerp(tab_open_position, speed)
	if(is_open == false):
		self.position = self.position.lerp(self_closed_position, speed)
		bank_container.position = bank_container.position.lerp(tab_closed_position, speed)

func _on_pressed() -> void:
	if(is_open == false):
		is_open = true
		sprite.flip_h = true
	else:
		is_open = false
		sprite.flip_h = false
