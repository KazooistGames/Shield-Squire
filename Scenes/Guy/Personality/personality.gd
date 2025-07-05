extends Area2D

const destination_deadband = 16

@export var Deadend := false
@export var Deadbanded := false
@export var Desired_Coordinates := Vector2.ZERO
@export var Active_Behaviour : Node = null

@onready var Me : CharacterBody2D = get_parent()
@onready var Behaviours = find_children('*_*') #implementation detail: use _ in state nodes w/ behaviour script

@onready var across : RayCast2D = $across
@onready var down : RayCast2D = $down


func _ready() -> void:
	
	Active_Behaviour = get_current_priority()


func _physics_process(delta : float) -> void:
	
	_position_raycasts()
	
	Desired_Coordinates = Active_Behaviour.Desired_Coordinates
	
	if not inside_deadband():
		Deadbanded = false
		Me.left_right = sign(Desired_Coordinates.x - global_position.x)
		
	elif not Deadbanded:
		Deadbanded = true
		Me.left_right = 0


func get_current_priority() -> Node:
	
	var highest_priority_so_far := 0
	var priority_state : Node = null
	
	for state in Behaviours:
		
		if priority_state == null:
			highest_priority_so_far = state.process_priority
			priority_state = state
			
		elif state.Yielding:
			pass
			
		elif state.Priority > highest_priority_so_far:
			highest_priority_so_far = state.process_priority
			priority_state = state
	
	return priority_state


func detected_bodies() -> Array[Node2D]:
	
	var overlapping_bodies : Array[Node2D] = get_overlapping_bodies()
	overlapping_bodies.erase(Me)
	return overlapping_bodies
	

func inside_deadband() -> bool:
	
	var disposition : Vector2 = Desired_Coordinates - global_position
	var slide_length = get_slide_length()

	if Me.is_on_floor():
		return disposition.length() - slide_length < destination_deadband
	else:
		return abs(disposition.x) - slide_length < destination_deadband


func get_slide_length():
	
	var time_to_stop = Me.velocity.x / (Me.acceleration)
	var average_speed = Me.velocity.x / 2.0
	return average_speed * time_to_stop
	

func dynamic_deadband():
	
	return Me.velocity.x / Me.speed * destination_deadband


func _position_raycasts():
	
	across.target_position.x = Me.facing_direction * 120
	
	if across.is_colliding():
		var point := across.get_collision_point()
		down.global_position.x = point.x
		down.global_position.y = point.y - 90
		
	else:
		down.position.x = across.target_position.x
		down.position.y = -down.target_position.y/2.0
	
	Deadend = _calculate_deadend()
	

func _calculate_deadend() -> bool:
	
	if not across.is_colliding():
		return false
		
	elif not down.is_colliding():
		return false
	
	else:
		var y_delta = down.get_collision_point().y - Me.global_position.y
		return y_delta < -Me.jump_height


	
