extends "res://Scenes/Guy/Personality/behaviours/behaviour.gd"


enum State {
	explore = 0,
	hide = 1,
}

var state : State = State.explore
var state_timer := 0.0
var state_completed := false
var min_state_time = 5
var max_state_time = 10


func _physics_process(delta: float) -> void:
	
	if personality.Me.state == personality.Me.State.dead:
		return
	
	if not Active:
		return

	
	
func _state_transitions(delta):
	
	state_timer += delta
	var early_completion = state_timer >= min_state_time and state_completed
	var timedout = state_timer >= max_state_time
	var charging = personality.Me.state == personality.Me.State.charging
	
	if (early_completion or timedout) and not charging:
		var next_state = calc_next_state()
		set_state(next_state)


	
func calc_next_state():
	
	return randi_range(0, 1)
	
	
func set_state(new_state : State):
	
	print('_explore: ', new_state)
	state_timer = 0.0
	state_completed = false
	state = new_state
	
	match state:
		
		State.explore:
			min_state_time = 5
			max_state_time = 10
			Desired_Coordinates = get_random_point_near_me()
		State.hide:
			min_state_time = 10
			max_state_time = 10


func get_random_point_near_me():
	
	var space_state : PhysicsDirectSpaceState2D = personality.Me.get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var x_offset = randi_range(48, 120)
	var y_offset = -60
	var starting_point = personality.Me.global_position + Vector2(x_offset, y_offset)
	var ending_point = starting_point - Vector2(0, y_offset)
	var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(Vector2(0, 0), Vector2(50, 100))
	query.collision_mask = 17
	var result = space_state.intersect_ray(query)
	
	return result['position']
