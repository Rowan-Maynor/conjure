extends Resource
class_name Skill_Data

@export var skill_max_upgrades: Dictionary = {
	"damage_basic": 10,
	"health_basic": 10,
	"research_basic": 5,
}

@export var skill_current_cost: Dictionary = {
	"damage_basic": 1,
	"health_basic": 1,
	"research_basic": 1,
}

@export var skill_current_upgrades: Dictionary = {
	"damage_basic": 0,
	"health_basic": 0,
	"research_basic": 0,
}

@export var spent_sp: int = 0
