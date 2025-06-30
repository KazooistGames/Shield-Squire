extends Area2D

const destination_deadband = 24

@export var Deadbanded := false
@export var Desired_Coordinates := Vector2.ZERO
@export var Me : CharacterBody2D
@export var Active_State : Node = null

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
	overlapping_bodies.erase(Me)
	return overlapping_bodies
	

func deadband_enter_action() -> void:
	
	Active_State.deadband_enter_action()
	
	
func deadband_exit_action() -> void:
	
	Active_State.deadband_exit_action()
