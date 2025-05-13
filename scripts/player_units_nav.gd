extends NavigationRegion2D

var needs_rebake: bool = false

func _physics_process(_delta: float) -> void:
	if(needs_rebake):
		needs_rebake = false
		call_deferred("rebake_navmesh")

func rebake_navmesh():
	self.bake_navigation_polygon()
