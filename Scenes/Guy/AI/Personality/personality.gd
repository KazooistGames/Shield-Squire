extends Area2D

const destination_deadband = 20

@export var Deadbanded := false
@export var Desired_Coordinates := Vector2.ZERO
@export var Me : CharacterBody2D
@export var Active_Behaviour : Node = null

@onready var Behaviours = find_children('*_*') #implementation detail: use _ in state nodes w/ behaviour script


func _ready() -> void:
	
	Active_Behaviour = get_current_priority()


func _process(delta : float) -> void:
	
	Desired_Coordinates = Active_Behaviour.Desired_Coordinates


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
	

#func deadband_enter_action() -> void:
	#
	#Active_Behaviour.deadband_enter_action()
	#
	#
#func deadband_exit_action() -> void:
	#
	#Active_Behaviour.deadband_exit_action()
