extends CharacterBody2D

@export var unit_data: Unit_Data
@export var recipe_data: Recipe_Data
@export var skill_data: Skill_Data

#targeting
var current_command: String = "idle"
var current_target: CharacterBody2D = null
@onready var attack_range: CollisionShape2D = $attack_range/CollisionShape2D

#this is for cases where the attack starts, but target exits attack range, resetting current_target
var attacked_target: CharacterBody2D = null

#navigation
var flow_field: Array = []
@onready var player_ffm: Node2D = get_tree().get_root().get_node(
	"game/flow_field_managers/player_ffm")
@onready var pathing_area: CollisionShape2D = $pathing_area/CollisionShape2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var chase: bool = false

#used to prevent animation overlap
var is_attacking: bool = false

#general functions
func _ready():
	if(unit_data.control == "enemy"):
		pathing_area.disabled = true
		attack_range.disabled = true
	
	if(unit_data.control == "player"):
		handle_unit_skill_values()
	
	#initialize nodes based on units data
	if ($attack_range/CollisionShape2D.shape):
		#need to duplicate the shape or if another unit spawns it will override the attack range
		$attack_range/CollisionShape2D.shape = $attack_range/CollisionShape2D.shape.duplicate(true)
		$attack_range/CollisionShape2D.shape.radius = unit_data.attack_range
	$attack_speed.wait_time = unit_data.attack_speed
	$health_bar.max_value = unit_data.health
	$health_bar.value = unit_data.health
	nav_agent.max_speed = unit_data.speed

func _physics_process(_delta: float) -> void:
	if(is_attacking == true):
		return
	if(flow_field.is_empty() == false):
		var curr_square: Vector2 = get_target_grid_position(self.position)
		var direction: Vector2 = flow_field[curr_square.x][curr_square.y].flow_vector
		velocity = direction * unit_data.speed
		if(direction == Vector2(0, 0)):
			change_state_idle()
		else:
			handle_anim(velocity)
			$AnimatedSprite2D.play("move")
			move_and_slide()
	if(chase == true):
		if(current_target):
			nav_agent.target_position = current_target.position
			var next_path_position: Vector2 = nav_agent.get_next_path_position()
			var intended_velocity: Vector2 = (next_path_position - self.position).normalized()
			nav_agent.set_velocity(intended_velocity * unit_data.speed)

#basic functionalities
func attack():
	if(current_target == null):
		return
	if($attack_speed.is_stopped()):
		nav_agent.set_velocity(Vector2.ZERO)
		attacked_target = current_target
		handle_attack_anim((current_target.position - position).normalized())
		$attack_speed.start()
		$attack_spawn_delay.start()

func die():
	#is_attacking used so that animation plays instead of more movement
	is_attacking = true
	$AnimatedSprite2D.play("death")
	emit_signal("died", self)
	self.queue_free()

#functions related to animations
func handle_anim(vector):
	if(vector.x > 0):
		$AnimatedSprite2D.flip_h = false
	elif(vector.x < 0):
		$AnimatedSprite2D.flip_h = true

func handle_attack_anim(vector):
	is_attacking = true
	print(vector)
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

#functions related to player unit aggro
func _on_attack_range_body_entered(body: Node2D) -> void:
	if(body.unit_data.control == "player"):
		return
	
	if(current_command == "focus"):
		if(current_target == body):
			attack()
	
	elif(current_command == "hold"):
		if(current_target == body):
			attack()
			return
		if(current_target == null):
			current_target = body
			current_target.died.connect(_on_died)
			attack()
			return
	
	elif(current_command == "idle"):
		if(current_target == null):
			change_state_focus()
			current_target = body
			current_target.died.connect(_on_died)
			attack()

func _on_attack_range_body_exited(body: Node2D) -> void:
	if(body.unit_data.control == "player"):
		return
	
	if(current_command == "hold"):
		if(current_target == body):
			reset_target()
			current_target = null
	
	elif(current_command == "focus"):
		if(current_target == body):
			chase = true

func find_new_target():
	var units: Array[Node2D] = $attack_range.get_overlapping_bodies()
	var enemy_units: Array[CharacterBody2D] = []
	for unit in units:
		#always filter out dead targets that are lingering in animation
		if (unit.unit_data.control == "enemy" && unit.unit_data.health > 0):
			enemy_units.append(unit)
	if(enemy_units.size() != 0):
		if(current_command != "hold"):
			change_state_focus()
		current_target = find_lowest_health_target(enemy_units)
		current_target.died.connect(_on_died)
	if(current_target != null):
		attack()

func reset_target():
	if(current_target != null):
		if(current_target.died.is_connected(_on_died)):
			current_target.died.disconnect(_on_died)
	if(chase == true):
		chase = false
	current_target = null
	nav_agent.target_position = self.position
	velocity = Vector2.ZERO

func _on_died(body):
	if (current_target == body):
		if(current_command != "hold"):
			change_state_idle()
		find_new_target()

#functions related to handleing unit attacks
func _on_attack_speed_timeout() -> void:
	$attack_speed.stop()
	var units_in_range: Array[Node2D] = $attack_range.get_overlapping_bodies()
	if(current_target != null && units_in_range.has(current_target)):
		attack()
	elif(current_command == "hold" || current_command == "idle"):
		if(current_target == null):
			find_new_target()

func _on_attack_animation_speed_timeout() -> void:
	is_attacking = false
	$AnimatedSprite2D.play("idle")

func _on_attack_contact(body, damage, element, is_critical):
	body.handle_damage(damage, element, is_critical)

func _on_attack_spawn_delay_timeout() -> void:
	if(attacked_target != null && is_instance_valid(attacked_target)):
		var attack_instance: Node = load(
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
		attack_instance.element = unit_data.element
		
		#check for crit
		var critical_check_value: int = randi_range(1, 100)
		if(unit_data.critical_chance > critical_check_value):
			attack_instance.is_critical = true
		else:
			attack_instance.is_critical = false
		
		attack_instance.attack_contact.connect(_on_attack_contact)
		get_tree().get_root().get_node("game").add_child(attack_instance)

#calculate functions
func calculate_critical_chance():
	var final_critical_chance: int = unit_data.critical_chance
	
	if(skill_data.skill_current_upgrades["critical_chance_basic"] > 0):
		for i in range(skill_data.skill_current_upgrades["critical_chance_basic"]):
			final_critical_chance += skill_data.skill_values["critical_chance_basic"]
	
	if(skill_data.skill_current_upgrades["critical_chance_intermediate"] > 0):
		for i in range(skill_data.skill_current_upgrades["critical_chance_intermediate"]):
			final_critical_chance += skill_data.skill_values["critical_chance_intermediate"]
	
	unit_data.set("critical_chance", final_critical_chance)

func calculate_range():
	var final_range: int = unit_data.attack_range
	
	if(skill_data.skill_current_upgrades["range_basic"] > 0):
		for i in range(skill_data.skill_current_upgrades["range_basic"]):
			final_range += skill_data.skill_values["range_basic"]
	
	unit_data.set("attack_range", final_range)

func calculate_critical_damage():
	var final_critical_damage: float = 2.0
	
	if(skill_data.skill_current_upgrades["critical_damage_basic"] > 0):
		for i in range(skill_data.skill_current_upgrades["critical_damage_basic"]):
			final_critical_damage += skill_data.skill_values["critical_damage_basic"]
			
	if(skill_data.skill_current_upgrades["critical_damage_intermediate"] > 0):
		for i in range(skill_data.skill_current_upgrades["critical_damage_intermediate"]):
			final_critical_damage += skill_data.skill_values["critical_damage_intermediate"]
	
	return final_critical_damage

func calculate_infusion_upgrade_count():
	unit_data.infusion_mult = 5

#helper functions
func find_lowest_health_target(targets):
	#TODO probably gotta change lowest to nearest target
	if(targets == null):
		return
	var lowest_health_target: CharacterBody2D = null
	for target in targets:
		if(target.unit_data.control == "player"):
			continue
		if (lowest_health_target == null):
			lowest_health_target = target
		if (target.unit_data.health < lowest_health_target.unit_data.health):
			lowest_health_target = target
	return lowest_health_target

func handle_unit_skill_values():
	calculate_critical_chance()
	calculate_range()
	calculate_infusion_upgrade_count()
	unit_data.infusion_mult = 1.0

func get_target_grid_position(pos: Vector2):
	var grid_pos: Vector2 = Vector2.ZERO
	grid_pos.x = (floori(pos.x / 16))
	grid_pos.y = (floori(pos.y / 16))
	return grid_pos

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	handle_anim(safe_velocity)
	$AnimatedSprite2D.play("move")
	move_and_slide()

#damage functions
func handle_damage(value: int, element: String, is_critical: bool):
	#update final_damage in game.gd aswell if you make changes here
	#otherwise the unit panel will not show proper data
	
	var is_element_advantage: bool = check_for_element_advantage(element)
	var is_element_disadvantage: bool = check_for_element_disadvantage(element)
	var final_damage: int = value
	
	#apply research damage increase
	if(element == "fire"):
		final_damage = floor(final_damage * get_tree().get_root().get_node("game").fire_research_value)
	elif(element == "water"):
		final_damage = floor(final_damage * get_tree().get_root().get_node("game").water_research_value)
	elif(element == "earth"):
		final_damage = floor(final_damage * get_tree().get_root().get_node("game").earth_research_value)
	
	#apply skill page increases
	var basic_skill_mult: float = 1.0
	if(skill_data.skill_current_upgrades["damage_basic"] > 0):
		for i in range(skill_data.skill_current_upgrades["damage_basic"]):
			basic_skill_mult += skill_data.skill_values["damage_basic"]
	final_damage = floor(final_damage * basic_skill_mult)
	
	var intermediate_skill_mult: float = 1.0
	if(skill_data.skill_current_upgrades["damage_intermediate"] > 0):
		for i in range(skill_data.skill_current_upgrades["damage_intermediate"]):
			intermediate_skill_mult += skill_data.skill_values["damage_intermediate"]
	final_damage = floor(final_damage * intermediate_skill_mult)
	
	#check for critical
	if(is_critical == true):
		var critical_damage = calculate_critical_damage()
		final_damage = floor(final_damage * critical_damage)
	
	#apply element advantage/disadvantage
	if(is_element_advantage):
		final_damage = ceil(final_damage * 1.2)
	elif(is_element_disadvantage):
		final_damage = floor(final_damage * 0.8)
	
	#deal final damage
	if(unit_data.health <= 0):
		return
	self.unit_data.health -= final_damage
	var damage_number_position: Vector2
	damage_number_position.x = self.global_position.x
	damage_number_position.y = self.global_position.y - 25
	damage_number(final_damage, damage_number_position, is_critical)
	$health_bar.value = unit_data.health
	if($health_bar.value < $health_bar.max_value):
		$health_bar.visible = true
	if(unit_data.health <= 0):
		die()
		return

func check_for_element_advantage(element):
	if(unit_data.element == "fire"):
		if(element == "water"):
			return true
		else:
			return false
	elif(unit_data.element == "earth"):
		if(element == "fire"):
			return true
		else:
			return false
	if(unit_data.element == "water"):
		if(element == "earth"):
			return true
		else:
			return false

func check_for_element_disadvantage(element):
	if(unit_data.element == "fire"):
		if(element == "earth"):
			return true
		else:
			return false
	elif(unit_data.element == "earth"):
		if(element == "water"):
			return true
		else:
			return false
	if(unit_data.element == "water"):
		if(element == "fire"):
			return true
		else:
			return false

func damage_number(value: int, hit_position: Vector2, is_critical = false):
	var number_label: Label = Label.new()
	number_label.position = hit_position
	number_label.text = str(value)
	number_label.z_index = 5
	
	var color: Color = Color.hex(0xffffffff)
	if(is_critical == true):
		color = Color.hex(0xff3e3eff)
	var label_theme: Resource = load("res://theme.tres")
	
	number_label.theme = label_theme
	number_label.add_theme_font_size_override("font_size", 16)
	number_label.set("theme_override_colors/font_color", color)
	
	get_tree().get_root().get_node("game").add_child(number_label)
	
	var tween_position: Vector2
	tween_position.x = number_label.position.x
	tween_position.y = number_label.position.y - 24
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(number_label, "position", tween_position, 1)
	tween.tween_callback(number_label.queue_free).set_delay(1)

#state functions
func change_state_idle():
	reset_target()
	current_command = "idle"
	flow_field = []
	pathing_area.set_deferred("disabled", false)
	$attack_spawn_delay.stop()
	$AnimatedSprite2D.play("idle")

func change_state_move():
	reset_target()
	current_command = "move"
	pathing_area.disabled = true
	$attack_spawn_delay.stop()

func change_state_hold():
	reset_target()
	current_command = "hold"
	flow_field = []
	pathing_area.set_deferred("disabled", false)
	$attack_spawn_delay.stop()
	$AnimatedSprite2D.play("idle")

func change_state_attack():
	reset_target()
	current_command = "attack"
	flow_field = []
	pathing_area.disabled = true
	$attack_spawn_delay.stop()

func change_state_focus():
	reset_target()
	current_command = "focus"
	flow_field = []
	pathing_area.set_deferred("disabled", true)
	$attack_spawn_delay.stop()

#signals
signal died(body)
