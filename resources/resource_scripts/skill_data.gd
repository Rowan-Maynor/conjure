extends Resource
class_name Skill_Data

#update this whenever you make changes to skills to force wipe old data
#this will force all users to make new skill pages so do skill page changes sparingly
@export var skill_version: int = 4

@export var skill_max_upgrades: Dictionary = {
	"damage_basic": 10,
	"lives_basic": 10,
	"research_basic": 5,
	"critical_chance_basic": 10,
	"critical_damage_basic": 10,
	"starting_mana_basic": 5,
	"range_basic": 5,
}

@export var skill_current_cost: Dictionary = {
	"damage_basic": 1,
	"lives_basic": 1,
	"research_basic": 5,
	"critical_chance_basic": 1,
	"critical_damage_basic": 1,
	"starting_mana_basic": 10,
	"range_basic": 1,
}

@export var skill_current_upgrades: Dictionary = {
	"damage_basic": 0,
	"lives_basic": 0,
	"research_basic": 0,
	"critical_chance_basic": 0,
	"critical_damage_basic": 0,
	"starting_mana_basic": 0,
	"range_basic": 0,
}

@export var skill_values: Dictionary = {
	"damage_basic": .05,
	"lives_basic": 1,
	"research_basic": 2,
	"critical_chance_basic": 1,
	"critical_damage_basic": .05,
	"starting_mana_basic": 1,
	"range_basic": 10,
}

@export var spent_sp: int = 0
