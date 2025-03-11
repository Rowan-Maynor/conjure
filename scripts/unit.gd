extends CharacterBody2D

const speed = 100
var click_position = Vector2()
var target_position = Vector2()

func _ready():
	click_position = position

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("right_click"):
		click_position = get_global_mouse_position()
	if Input.is_action_just_pressed("stop_movement"):
		click_position = position
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		move_and_slide()
