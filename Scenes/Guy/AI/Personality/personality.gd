extends Area2D

@export var Active_State : Node = null
@export var Desired_Coordinates := Vector2.ZERO
@export var Detection_Exceptions : Array[Node2D] = []


@onready var States = find_children('*_*') #implementation detail: use _ in state nodes w/ behaviour script


func _ready() -> void:
	
	Active_State = get_current_priority()


func _process(delta : float) -> void:
	
	Desired_Coordinates = Active_State.Desired_Coordinates


func get_current_priority() -> Node:
	
	var highest_priority_so_far := 0
	var priority_state : Node = null
	
	for state in States:
		
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
	
	for exception in Detection_Exceptions:
		overlapping_bodies.erase(exception)
	
	return overlapping_bodies
