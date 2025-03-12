extends CharacterBody2D

#variables for unit properites
@export var damage = 2
@export var health = 10
@export var speed = 100
@export var current_command = "stop"
@export var control = "player"

#variables for navigation
var click_position = Vector2()
var target_position = Vector2()
var current_direction = "down"
@onready var nav = $NavigationAgent2D
var enemy_direction = "down"

func _ready():
	#this prevents units from running to (0, 0) on spawn
	click_position = position
	#defaults spawned enemies to moving downwards on spawn
	if(control == "enemy"):
		enemy_change_direction(enemy_direction)

func _physics_process(_delta: float) -> void:
	#handles updating the path of enemies when they get near corners
	if (target_position.y - position.y <= 3 && control == "enemy" && enemy_direction == "down"):
		enemy_direction = "right"
		enemy_change_direction(enemy_direction)
	if (target_position.x - position.x <= 3 && control == "enemy" && enemy_direction == "right"):
		enemy_direction = "up"
		enemy_change_direction(enemy_direction)
	if (position.y - target_position.y <= 3 && control == "enemy" && enemy_direction == "up"):
		enemy_direction = "left"
		enemy_change_direction(enemy_direction)
	if (position.x - target_position.x <= 3 && control == "enemy" && enemy_direction == "left"):
		enemy_direction = "down"
		enemy_change_direction(enemy_direction)
	
	#resolves enemy movement if they are more than 3 pixels from target
	if (position.distance_to(target_position) > 3 && control == "enemy"):
		var next_nav_location = nav.get_next_path_position()
		var nav_target_position = (next_nav_location - position).normalized()
		velocity = nav_target_position * speed
		handle_anim(nav_target_position)
		move_and_slide()
		
	#resolves player movement if they are more than 3 pixels away from click
	if (position.distance_to(click_position) > 3 && control == "player"):
		target_position = (click_position - position).normalized()
		velocity = target_position * speed
		handle_anim(target_position)
		move_and_slide()
		
	#sets animation to idle if unit stops moving
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

func enemy_change_direction(direction):
	#random number used to make enemy path fell less linear
	var rng = RandomNumberGenerator.new()
	var variance = 20.0
	if(direction == "right"):
		var path_node = get_tree().get_root().get_node("game/enemy_path_points/bottom_right")
		target_position = path_node.position
		target_position.x += rng.randf_range(-variance, variance)
		target_position.y += rng.randf_range(-variance, variance)
		update_target_position(target_position)
	if(direction == "up"):
		var path_node = get_tree().get_root().get_node("game/enemy_path_points/top_right")
		target_position = path_node.position
		target_position.x += rng.randf_range(-variance, variance)
		target_position.y += rng.randf_range(-variance, variance)
		update_target_position(target_position)
	if(direction == "left"):
		var path_node = get_tree().get_root().get_node("game/enemy_path_points/top_left")
		target_position = path_node.position
		target_position.x += rng.randf_range(-variance, variance)
		target_position.y += rng.randf_range(-variance, variance)
		update_target_position(target_position)
	if(direction == "down"):
		var path_node = get_tree().get_root().get_node("game/enemy_path_points/bottom_left")
		target_position = path_node.position
		target_position.x += rng.randf_range(-variance, variance)
		target_position.y += rng.randf_range(-variance, variance)
		update_target_position(target_position)
