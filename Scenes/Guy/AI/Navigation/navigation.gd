extends Node2D

@export var Me : CharacterBody2D
@export var RayRange := Vector2(120, 200)
@export var Direction := 1
@export var Deadend := false

@onready var across : RayCast2D = $across
@onready var down : RayCast2D = $down


func _physics_process(delta : float) -> void:
	
	across.target_position.x = Me.facing_direction * RayRange.x
	
	if across.is_colliding():
		var point := across.get_collision_point()
		down.global_position.x = point.x
		down.global_position.y = point.y - RayRange.y
		
	else:
		down.position.x = across.target_position.x
		down.position.y = -RayRange.y/2.0
	
	Deadend = _calculate_deadend()
	

func set_ranges(new_ranges : Vector2):
	
	RayRange = abs(new_ranges)
	across.target_position = Vector2(-abs(RayRange.x), 0)
	down.target_position = Vector2(0, abs(RayRange.y))


func _calculate_deadend() -> bool:
	
	if not across.is_colliding():
		return false
		
	elif not down.is_colliding():
		return false
	
	else:
		var y_delta = down.get_collision_point().y - Me.global_position.y
		return y_delta < -Me.jump_height
		
		
