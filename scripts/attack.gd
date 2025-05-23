extends CharacterBody2D

@export var attack_data: Attack_Data

#current_target will be set by unit that attacks, but kept track of here
@export var current_target: CharacterBody2D = null

#this will keep track of how far ABOVE the sprite for the attack to make contact
var y_diff: float = 10.0

@export var enemy_position: Vector2
@export var damage: int
@export var element: String
@export var is_critical: bool

func _ready() -> void:
	if(attack_data.type == "melee"):
		emit_signal("attack_contact", current_target, damage, element, is_critical)

func _physics_process(_delta:float) -> void:
	if(attack_data.type != "melee"):
		if(current_target == null):
			queue_free()
			return
		if(!is_instance_valid(current_target)):
			queue_free()
			return
		if(current_target.is_queued_for_deletion()):
			queue_free()
			return
		
		enemy_position.x = current_target.position.x
		enemy_position.y = current_target.position.y - y_diff
		
		$AnimatedSprite2D.look_at(enemy_position)
		
		if(position.distance_to(enemy_position) < 6):
			emit_signal("attack_contact", current_target, damage, element, is_critical)
			self.queue_free()
		
		elif(position.distance_to(enemy_position) > 3):
			var target_position: Vector2 = (enemy_position - position).normalized()
			velocity = target_position * attack_data.speed
			move_and_slide()

signal attack_contact(body, damage, element, is_critical)


func _on_animated_sprite_2d_animation_finished() -> void:
	self.queue_free()
