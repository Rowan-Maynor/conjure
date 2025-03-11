extends CharacterBody2D

var damage = 2
var health = 10
const speed = 100
var current_command = "stop"
@export var control = "player"

var click_position = Vector2()
var target_position = Vector2()
var current_direction = "down"
@onready var nav = $NavigationAgent2D

func _ready():
	click_position = position
	if(control == "enemy"):
		target_position.x = 864.0
		target_position.y = 448.0
		update_target_position(target_position)

func _physics_process(_delta: float) -> void:
	if (position.distance_to(target_position) > 3 && control == "enemy"):
		var next_nav_location = nav.get_next_path_position()
		var nav_target_position = (next_nav_location - position).normalized()
		velocity = nav_target_position * speed
		handle_anim(nav_target_position)
		move_and_slide()
	if (position.distance_to(click_position) > 3 && control == "player"):
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		handle_anim(target_position)
		move_and_slide()
	if (position.distance_to(click_position) < 3 && control == "player"):
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
		
func update_target_position(target):
	nav.set_target_position(target)
