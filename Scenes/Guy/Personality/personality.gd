extends Area2D

const deadband_radius = 16

enum TravelMode {
	traversing,
	climbing,
	descending
}
@export var travel_mode : TravelMode = TravelMode.traversing

@export var Deadbanded := false
@export var Desired_Coordinates := Vector2.ZERO
@export var Active_Behaviour : Node = null

@onready var Me : CharacterBody2D = get_parent()
@onready var Behaviours = find_children('*_*') #implementation detail: use _ in state nodes w/ behaviour script

@onready var across : RayCast2D = $across
@onready var down : RayCast2D = $down
@onready var above : RayCast2D = $above

var displacement := Vector2.ZERO
var cached_coordinates := Vector2.ZERO


func _ready() -> void:
	
	Active_Behaviour = get_current_priority()
	Me.fell.connect(_handle_fall)


func _physics_process(delta : float) -> void:
	
	_position_raycasts()
	
	Desired_Coordinates = Active_Behaviour.Desired_Coordinates
	
	if cached_coordinates != Desired_Coordinates:
		Deadbanded = false
		cached_coordinates = Desired_Coordinates
		
	displacement = Desired_Coordinates - global_position
	#print(displacement)
	
	if Deadbanded:
		pass
	if inside_deadband():
		Me.left_right = 0
		Deadbanded = true
	elif displacement.y <= -deadband_radius: #start dropping to target
		_climb(delta)
	elif abs(displacement.x) > deadband_radius:
		Me.left_right = sign(displacement.x)
	elif displacement.y > -deadband_radius:
		_descend(delta)

	
		
		
func _climb(delta : float) -> void:
	
	if not Me.is_on_floor(): #in the air - lock in the trajectory we got by not changing left_right controls
		return
		
	if above.is_colliding():
		Me.left_right = 0
		Me.jump()
		
	elif Me.left_right == 0:
		Me.left_right = sign(displacement.x)
	
	elif is_deadended():
		print('deadended')
		Me.left_right *= -1
		

func _descend(delta : float) -> void:
	
	if not Me.is_on_floor():
		return
	else:
		Me.duck()


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


func is_deadended() -> bool:
	
	if not across.is_colliding():
		return false
		
	elif not down.is_colliding():
		return false
	
	else:
		var y_delta = down.get_collision_point().y - Me.global_position.y
		return y_delta <= -Me.jump_height
		
		
func detected_bodies() -> Array[Node2D]:
	
	var overlapping_bodies : Array[Node2D] = get_overlapping_bodies()
	overlapping_bodies.erase(Me)
	return overlapping_bodies
	

func inside_deadband() -> bool:
	
	var disposition : Vector2 = Desired_Coordinates - global_position
	var slide_length = get_slide_length()

	if Me.is_on_floor():
		return disposition.length() - slide_length < deadband_radius
	else:
		return false


func get_slide_length():
	
	var time_to_stop = Me.velocity.x / (Me.acceleration)
	var average_speed = Me.velocity.x / 2.0
	return average_speed * time_to_stop


func _position_raycasts():
	
	across.target_position.x = Me.facing_direction * 48
	
	if across.is_colliding():
		var point := across.get_collision_point()
		down.global_position.x = point.x
		down.global_position.y = point.y - down.target_position.y/2.0
		
	else:
		down.position.x = across.target_position.x
		down.position.y = -down.target_position.y/2.0
		

func _handle_fall():
	
	if displacement.y < -deadband_radius: #start dropping to target
		Me.jump()
	elif abs(displacement.y) < deadband_radius:
		Me.jump()
		


	
