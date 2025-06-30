extends Node2D

@export var RayRange := Vector2(240, 240)
@export var Direction := 1

@onready var horizontal : RayCast2D = $forward_horizontal
@onready var vertical : RayCast2D = $forward_vertical


func _process(delta : float) -> void:
	
	if horizontal.is_colliding():
		var point := horizontal.get_collision_point()
		vertical.global_position.x = point.x
		vertical.global_position.y = point.y - RayRange.y
		
		
	else:
		vertical.position.x = horizontal.target_position.x
		vertical.position.y = -RayRange.y/2.0


		

func set_ranges(new_ranges : Vector2):
	
	RayRange = abs(new_ranges)
	horizontal.target_position = Vector2(-abs(RayRange.x), 0)
	vertical.target_position = Vector2(0, abs(RayRange.y))
