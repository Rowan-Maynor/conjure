extends CharacterBody2D

var damage = 2
var health = 10
const speed = 100
var current_command = "stop"
var control = "player"

var click_position = Vector2()
var target_position = Vector2()
var current_direction = "down"

func _ready():
	click_position = position

func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("stop_movement"):
		#click_position = position
		#current_command = "stop"
	if position.distance_to(click_position) > 3:
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		handle_anim(target_position)
		move_and_slide()
	if (position.distance_to(click_position) < 3):
		$AnimatedSprite2D.play("idle_" + current_direction)
		if(current_command == "move"):
			current_command = "stop"

func handle_anim(vector):
	if(vector.x > 0 && abs(vector.x) > abs(vector.y)):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("move_side")
		current_direction = "side"
	elif(vector.x < 0 && abs(vector.x) > abs(vector.y)):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("move_side")
		current_direction = "side"
	elif(vector.y > 0 && abs(vector.y) > abs(vector.x)):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("move_down")
		current_direction = "down"
	elif(vector.y < 0 && abs(vector.y) > abs(vector.x)):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("move_up")
		current_direction = "up"
		
