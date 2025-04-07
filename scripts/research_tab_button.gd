extends Button

var shift_ammount = 65
var self_closed_position: Vector2
var self_open_position: Vector2
var tab_closed_position: Vector2
var tab_open_position: Vector2
var speed = .2
var is_open = false
@onready var research_buttons_tab = $"../research_tab_buttons"

func _ready():
	self_closed_position.x = 912
	self_closed_position.y = 150
	self_open_position.x = self_closed_position.x - shift_ammount
	self_open_position.y = 150
	tab_closed_position.x = 960
	tab_closed_position.y = 90
	tab_open_position.x = tab_closed_position.x - shift_ammount
	tab_open_position.y = 90

func _physics_process(_delta: float) -> void:
	if(is_open == true):
		self.position = self.position.lerp(self_open_position, speed)
		research_buttons_tab.position = research_buttons_tab.position.lerp(tab_open_position, speed)
	if(is_open == false):
		self.position = self.position.lerp(self_closed_position, speed)
		research_buttons_tab.position = research_buttons_tab.position.lerp(tab_closed_position, speed)

func _on_pressed() -> void:
	if(is_open == false):
		is_open = true
	else:
		is_open = false
