extends CharacterBody2D

@export var attack_data: Attack_Data

#TODO current_target will be set by unit that attacks, but kept track of here
@export var current_target = null
#this will keep track of how far ABOVE the sprite for the attack to make contact
var y_diff = 10.0
@export var enemy_position = Vector2()
#damage needs to be calculated by the unit and passed to the attack which will then also be
#passed in the emit signal so the enemy knows how much damage to take
@export var damage: int
#needs to emit signal when position == curren_target.position
func _ready() -> void:
	if(attack_data.type == "melee"):
		emit_signal("attack_contact", current_target, damage)

func _physics_process(_delta:float) -> void:
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
	
	if(attack_data.type != "melee"):
		$Sprite2D.look_at(enemy_position)
		
	
	if(position.distance_to(enemy_position) < 6 && attack_data.type != "melee"):
		emit_signal("attack_contact", current_target, damage)
		self.queue_free()
	
	elif(position.distance_to(enemy_position) > 3 && attack_data.type != "melee"):
		var target_position = (enemy_position - position).normalized()
		velocity = target_position * attack_data.speed
		move_and_slide()
	
#emit signal needs to pass its current_target so the unit that needs to be damaged is recognized
signal attack_contact(body, damage)


func _on_animated_sprite_2d_animation_finished() -> void:
	self.queue_free()
