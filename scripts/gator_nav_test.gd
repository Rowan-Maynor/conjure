extends CharacterBody2D

@onready var obstacle = $NavigationObstacle2D
@export var unit_data: Unit_Data
@export var recipe_data: Recipe_Data


func _ready():
	# Define the obstacle shape with vertices
	obstacle.vertices = [
		Vector2(-24, -40),
		Vector2(24, -40),
		Vector2(24, 40),
		Vector2(-24, 40),
	]

	# Make sure the obstacle is carving the navigation mesh
	obstacle.carve_navigation_mesh = true
	# Link the obstacle to the correct navigation map
	obstacle.set_navigation_map(get_world_2d().navigation_map)
	print(obstacle.get_navigation_map() == get_world_2d().navigation_map)
