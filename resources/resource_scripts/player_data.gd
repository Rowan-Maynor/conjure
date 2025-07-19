extends Resource
class_name Player_Data

#update this value any time changes are made to player data
#be sure to also update the function on ready in main menu to match
@export var version: int = 1

@export var sp: int = 0

@export var recipe_unlocks: Dictionary = {
	"demon": false,
	"hound": false,
	"skipper": false,
	"shaman": false,
	"guardian": false,
	"idol": false,
	"hell_hound": false,
	"naga": false,
	"great_ape": false,
}

@export var skill_page_unlocks: Dictionary = {
	"intermediate": false,
	"advanced": false,
}
