extends CharacterBody2D

@export var unit_data: Unit_Data
@export var recipe_data: Recipe_Data

#targeting
var current_command = "idle"
var current_target = null

#this is for cases where the attack starts, but target exits attack range, resetting current_target
var attacked_target = null

#navigation
var move_position = Vector2()
var target_position = Vector2()
var chase = false
@onready var nav = $NavigationAgent2D
var enemy_direction = "down"

#used to prevent animation overlap
var is_attacking = false

#general functions
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
	#initialize nodes based on units data
	if $attack_range/CollisionShape2D.shape:
		#need to duplicate the shape or if another unit spawns it will override the attack range
		$attack_range/CollisionShape2D.shape = $attack_range/CollisionShape2D.shape.duplicate(true)
		$attack_range/CollisionShape2D.shape.radius = unit_data.attack_range
	$attack_speed.wait_time = unit_data.attack_speed
	$health_bar.max_value = unit_data.health
	$health_bar.value = unit_data.health

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
		#need to do this because if a unit is queued to be freed on the same frame
		#as when you try to get the posiion for the chase the game will crash
		if(current_target != null):
			move_position = current_target.position
		#there is a case where a unit will be in the idle state chasing a target
		#i am not sure why its happening so this is a bandaid fix
		elif(current_command == "idle"):
			chase = false
		else:
			chase = false
	#resolves enemy movement if they are more than 3 pixels from target
	if (position.distance_to(target_position) > 3 && unit_data.control == "enemy"):
		var next_nav_location = nav.get_next_path_position()
		var nav_target_position = (next_nav_location - position).normalized()
		velocity = nav_target_position * unit_data.speed
		if(is_attacking == false):
			handle_anim(nav_target_position)
			move_and_slide()
		
	#resolves player movement if they are more than 3 pixels away from click
	if (position.distance_to(move_position) > 3 && unit_data.control == "player"):
		target_position = (move_position - position).normalized()
		velocity = target_position * unit_data.speed
		if(is_attacking == false):
			handle_anim(target_position)
			move_and_slide()
		
	#sets animation to idle if unit stops moving
	if (position.distance_to(move_position) < 3 && unit_data.control == "player"):
		if(is_attacking == false):
			$AnimatedSprite2D.play("idle")
		if(current_command == "move"):
			current_command = "idle"

#basic functionalities
func attack():
	if(current_target == null):
		return
	if($attack_speed.is_stopped()):
		attacked_target = current_target
		handle_attack_anim((current_target.position - position).normalized())
		$attack_speed.start()
		$attack_spawn_delay.start()

func die():
	#is_attacking used so that animation plays instead of more movement
	is_attacking = true
	move_position = position
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("death")
	emit_signal("died", self)

#functions related to animations
func handle_anim(vector):
	if(vector.x > 0):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("move")
	elif(vector.x < 0):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("move")

func handle_attack_anim(vector):
	is_attacking = true
	if(vector.x > 0):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("attack")
	elif(vector.x < 0):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("attack")
	$attack_animation_speed.start()

func _on_animated_sprite_2d_animation_finished() -> void:
	if($AnimatedSprite2D.animation == "death"):
		queue_free()
	else:
		return

#functions related to enemy pathing
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

#functions related to player unit aggro
func _on_attack_range_body_entered(body: Node2D) -> void:
	#only allow players to attack enemies, not vice versa
	if(unit_data.control == "enemy"):
		return
	if(body.unit_data.control == "player"):
		return
	if(!is_instance_valid(body)):
		return
	if(current_command == "idle" || current_command == "attack"):
		if(current_target == null && body.unit_data.control == "enemy"):
			current_target = body
			if(!current_target.died.is_connected(_on_died)):
				current_target.died.connect(_on_died)
			current_command = "focus"
			attack()
	elif(current_command == "focus" && current_target == body):
		attack()
	elif(current_command == "hold" && current_target == null):
		current_target = body
		if(!current_target.died.is_connected(_on_died)):
			current_target.died.connect(_on_died)
		attack()

func _on_attack_range_body_exited(body: Node2D) -> void:
	if(body.is_queued_for_deletion()):
		return
	if(body == current_target):
		if(!is_instance_valid(current_target)):
			reset_target()
			return
		if(current_target.is_queued_for_deletion()):
			reset_target()
			return
		#if target is valid and not queued for deletion chase
		if(current_command != "hold"):
			chase = true
			current_command = "focus"
		if(current_command == "hold"):
			reset_target()

func find_new_target():
	var units = $attack_range.get_overlapping_bodies()
	var enemy_units = []
	for unit in units:
		#always filter out dead targets that are lingering in animation
		if (unit.unit_data.control == "enemy" && unit.unit_data.health > 0):
			enemy_units.append(unit)
	if(enemy_units.size() != 0):
		current_target = find_lowest_health_target(enemy_units)
		current_target.died.connect(_on_died)
	if(current_target != null):
		attack()

func reset_target():
	if(current_target != null):
		current_target.died.disconnect(_on_died)
	chase = false
	current_target = null
	move_position = self.position

func _on_died(body):
	if (current_target == body):
		reset_target()
		if(current_command != "hold"):
			current_command = "idle"
		find_new_target()

#functions related to handleing unit attacks
func _on_attack_speed_timeout() -> void:
	$attack_speed.stop()
	var units_in_range = $attack_range.get_overlapping_bodies()
	if(current_target != null && units_in_range.has(current_target)):
		attack()
	elif(current_command == "hold" || current_command == "idle"):
		if(current_target == null):
			find_new_target()

func _on_attack_animation_speed_timeout() -> void:
	is_attacking = false

func _on_attack_contact(body, damage):
	body.handle_damage(damage)

func _on_attack_spawn_delay_timeout() -> void:
	if(attacked_target != null && is_instance_valid(attacked_target)):
		var attack_instance = load(
			"res://scenes/attacks/" + unit_data.attack + ".tscn").instantiate()
		attack_instance.attack_data = load(
			"res://resources/attacks/" + unit_data.attack + ".tres").duplicate()
		attack_instance.z_index = 2
		if(attack_instance.attack_data.type == "melee"):
			attack_instance.position = attacked_target.position
			if($AnimatedSprite2D.flip_h == true):
				attack_instance.get_node("AnimatedSprite2D").flip_h = true
		else:
			if($AnimatedSprite2D.flip_h == false):
				attack_instance.position.x = self.position.x + 10.0
				attack_instance.position.y = self.position.y - 5.0
			if($AnimatedSprite2D.flip_h == true):
				attack_instance.position.x = self.position.x - 5.0
				attack_instance.position.y = self.position.y - 5.0
		attack_instance.current_target = attacked_target
		attack_instance.damage = unit_data.damage
		attack_instance.attack_contact.connect(_on_attack_contact)
		get_tree().get_root().get_node("game").add_child(attack_instance)

#helper functions
func find_lowest_health_target(targets):
	#TODO probably gotta change lowest to nearest target
	if(targets == null):
		return
	var lowest_health_target = null
	for target in targets:
		if(target.unit_data.control == "player"):
			continue
		if (lowest_health_target == null):
			lowest_health_target = target
		if (target.unit_data.health < lowest_health_target.unit_data.health):
			lowest_health_target = target
	return lowest_health_target

func handle_damage(value):
	if(unit_data.health <= 0):
		return
	self.unit_data.health -= value
	$health_bar.value = unit_data.health
	if($health_bar.value < $health_bar.max_value):
		$health_bar.visible = true
	if(unit_data.health <= 0):
		die()
		return

#signals
signal died(body)
