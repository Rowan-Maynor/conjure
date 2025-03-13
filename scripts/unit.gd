extends CharacterBody2D

@export var unit_data: Unit_data

var current_command = "idle"
var current_target = null

#variables for navigation
var move_position = Vector2()
var target_position = Vector2()
var current_direction = "down"
var chase = false
@onready var nav = $NavigationAgent2D
var enemy_direction = "down"

func _ready():
	#this prevents units from running to (0, 0) on spawn
	move_position = position
	#defaults spawned enemies to moving downwards on spawn
	if(unit_data.control == "enemy"):
		enemy_change_direction(enemy_direction)
	#this causes units to clot less around the square
	#however it also makes them jitter like crazy if they do clot
	if(unit_data.control == "enemy"):
		self.safe_margin = 1.0
	if($attack_range != null):
		get_node("attack_range/CollisionShape2D").shape.radius = unit_data.attack_range

func _physics_process(_delta: float) -> void:
	#handles updating the path of enemies when they get near corners
	if (target_position.y - position.y <= 3 && unit_data.control == "enemy" && enemy_direction == "down"):
		enemy_direction = "right"
		enemy_change_direction(enemy_direction)
	if (target_position.x - position.x <= 3 && unit_data.control == "enemy" && enemy_direction == "right"):
		enemy_direction = "up"
		enemy_change_direction(enemy_direction)
	if (position.y - target_position.y <= 3 && unit_data.control == "enemy" && enemy_direction == "up"):
		enemy_direction = "left"
		enemy_change_direction(enemy_direction)
	if (position.x - target_position.x <= 3 && unit_data.control == "enemy" && enemy_direction == "left"):
		enemy_direction = "down"
		enemy_change_direction(enemy_direction)
	
	if (chase == true):
		move_position = current_target.position
	#resolves enemy movement if they are more than 3 pixels from target
	if (position.distance_to(target_position) > 3 && unit_data.control == "enemy"):
		var next_nav_location = nav.get_next_path_position()
		var nav_target_position = (next_nav_location - position).normalized()
		velocity = nav_target_position * unit_data.speed
		handle_anim(nav_target_position)
		move_and_slide()
		
	#resolves player movement if they are more than 3 pixels away from click
	if (position.distance_to(move_position) > 3 && unit_data.control == "player"):
		target_position = (move_position - position).normalized()
		velocity = target_position * unit_data.speed
		handle_anim(target_position)
		move_and_slide()
		
	#sets animation to idle if unit stops moving
	if (position.distance_to(move_position) < 3 && unit_data.control == "player"):
		$AnimatedSprite2D.play("idle_" + current_direction)
		if(current_command == "move"):
			current_command = "idle"

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

#used for enemies pathing around square
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

func _on_attack_range_body_entered(body: Node2D) -> void:
	#only allow players to attack enemies, not vice versa
	if(unit_data.control == "enemy"):
		return
	if(current_command == "idle" || current_command == "attack"):
		if(current_target == null && body.unit_data.control == "enemy"):
			current_target = body
			current_target.died.connect(_on_died)
			current_command = "focus"
			attack()
	elif(current_command == "focus" && current_target == body):
		chase = false
		attack()

func _on_attack_range_body_exited(body: Node2D) -> void:
	if(body == current_target):
		chase = true

func attack():
	if(current_target == null):
		return
	if($attack_speed.is_stopped()):
		print(current_target)
		current_target.unit_data.health -= unit_data.damage
		$attack_speed.start(unit_data.attack_speed)
		if(current_target.unit_data.health <= 0):
			current_target.die()

func die():
	emit_signal("died", self)
	queue_free()

signal died(body)

func _on_died(body):
	if (current_target == body):
		current_target = null
		current_command = "idle"
		move_position = self.position

func _on_attack_speed_timeout() -> void:
	$attack_speed.stop()
	if(current_target == null):
		return
	var units_in_range = $attack_range.get_overlapping_bodies()
	if(units_in_range.has(current_target)):
		attack()
