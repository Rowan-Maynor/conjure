extends Resource
class_name Skill_Data

#update this whenever you make changes to skills to force wipe old data
#this will force all users to make new skill pages so do skill page changes sparingly
@export var skill_version: int = 8

@export var skill_max_upgrades: Dictionary = {
	"damage_basic": 10,
	"lives_basic": 10,
	"research_basic": 5,
	"critical_chance_basic": 10,
	"critical_damage_basic": 10,
	"starting_mana_basic": 5,
	"range_basic": 5,
	"damage_intermediate": 10,
	"bank_cap_intermediate": 1,
	"luck_intermediate": 5,
	"research_intermediate": 5,
	"critical_chance_intermediate": 10,
	"critical_damage_intermediate": 10,
	"starting_mana_intermediate": 5,
	"bank_research_advanced": 1,
	"luck_advanced": 5,
	"research_advanced": 5,
}

@export var skill_current_cost: Dictionary = {
	"damage_basic": 1,
	"lives_basic": 1,
	"research_basic": 5,
	"critical_chance_basic": 1,
	"critical_damage_basic": 1,
	"starting_mana_basic": 10,
	"range_basic": 1,
	"damage_intermediate": 10,
	"bank_cap_intermediate": 100,
	"luck_intermediate": 10,
	"research_intermediate": 50,
	"critical_chance_intermediate": 10,
	"critical_damage_intermediate": 10,
	"starting_mana_intermediate": 100,
	"bank_research_advanced": 250,
	"luck_advanced": 50,
	"research_advanced": 50,
}

@export var skill_current_upgrades: Dictionary = {
	"damage_basic": 0,
	"lives_basic": 0,
	"research_basic": 0,
	"critical_chance_basic": 0,
	"critical_damage_basic": 0,
	"starting_mana_basic": 0,
	"range_basic": 0,
	"damage_intermediate": 0,
	"bank_cap_intermediate": 0,
	"luck_intermediate": 0,
	"research_intermediate": 0,
	"critical_chance_intermediate": 0,
	"critical_damage_intermediate": 0,
	"starting_mana_intermediate": 0,
	"bank_research_advanced": 0,
	"luck_advanced": 0,
	"research_advanced": 0,
}

@export var skill_values: Dictionary = {
	"damage_basic": .05,
	"lives_basic": 1,
	"research_basic": 2,
	"critical_chance_basic": 1,
	"critical_damage_basic": .05,
	"starting_mana_basic": 1,
	"range_basic": 10,
	"damage_intermediate": .05,
	"bank_cap_intermediate": 1,
	"luck_intermediate": 1,
	"research_intermediate": 2,
	"critical_chance_intermediate": 1,
	"critical_damage_intermediate": .05,
	"starting_mana_intermediate": 1,
	"bank_research_advanced": 0,
	"luck_advanced": 1,
	"research_advanced": 2,
}

@export var spent_sp: int = 0
