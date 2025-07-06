extends "res://Scenes/Guy/Personality/behaviours/behaviour.gd"

const swing_range = 20

@export var Foe : CharacterBody2D = null
		
enum State {
	wait = 0,
	charge = 1,
	flee = 2,
}

var state : State = State.charge	
var state_timer := 0.0
var state_completed := false
var swing_cooldown_timer := 0.0
var swing_cooldown_period := 0.0

var disposition := Vector2.ZERO
var min_state_time = 3
var max_state_time = 10

var quick_swing := false
var yield_delay_period := 3.0
var yield_delay_timer := 0.0


func _physics_process(delta) -> void:
	
	swing_cooldown_timer += delta
	_determine_foe()
	
	if Foe:
		Yielding = false
		yield_delay_timer = 0.0
		
	elif yield_delay_timer < yield_delay_period:
		yield_delay_timer += delta
		
	else:
		Yielding = true

	
	if Yielding:
		return
	
	disposition = Foe.global_position - personality.Me.global_position
		

	_state_transitions(delta)
	_swing_reflex()
		
	match state:
		
		State.charge:
			Desired_Coordinates = Foe.global_position
			
		State.flee:
			Desired_Coordinates = personality.Me.global_position - disposition.normalized() * 100
					
		State.wait:
			personality.Me.turn_toward(Foe)
			

func _determine_foe():
	
	if not Foe:

		for body in personality.detected_bodies():
			
			if not body is CharacterBody2D:
				pass
				
			elif _can_see_through_all_concealments(body) :
				Foe = body
				
	elif not personality.detected_bodies().has(Foe):
		Foe = null
		Desired_Coordinates = personality.global_position
		
	elif not _can_see_through_all_concealments(Foe):
		Foe = null
		Desired_Coordinates = personality.global_position


func _state_transitions(delta):
	
	state_timer += delta
	var early_completion = state_timer >= min_state_time and state_completed
	var timedout = state_timer >= max_state_time
	var charging = personality.Me.state == personality.Me.State.charging
	
	if (early_completion or timedout) and not charging:
		var next_state = calc_next_state()
		set_state(next_state)


func _swing_reflex():
	
	var in_range = disposition.length() - personality.get_slide_length() <= swing_range
	var swing_ready = swing_cooldown_timer >= swing_cooldown_period
	
	if in_range and swing_ready:
		personality.Me.turn_toward(Foe)
		personality.Me.charge()
		
		if quick_swing:
			personality.Me.release()
			
		state_completed = true
		swing_cooldown_timer = 0.0


func _can_see_through_all_concealments(other_guy : CharacterBody2D) -> bool:
	
	print(other_guy.Concealments)
	print(personality.Me.Concealments)
	for concealment in other_guy.Concealments:
		
		if concealment == null:
			continue
		elif not personality.Me.Concealments.has(concealment):
			return false
	
	return true
	
	
func calc_next_state():
	
	return randi_range(1, 1)
	
	
func set_state(new_state : State):
	
	print('_fight: ', new_state)
	state_timer = 0.0
	state_completed = false
	state = new_state
	
	match state:
		
		State.charge:
			swing_cooldown_period = 0.0
			min_state_time = 5
			max_state_time = 10
			quick_swing = false
			
		State.flee:
			swing_cooldown_period = 3.0
			min_state_time = 10
			max_state_time = 15
			quick_swing = false
					
		State.wait:
			Desired_Coordinates = personality.Me.global_position
			swing_cooldown_period = 1.0
			min_state_time = 3
			max_state_time = 5
			quick_swing = true
			

func dynamic_range_factor():
	
	var slide = personality.get_slide_length()
	var relative_velocity = Foe.velocity.x - Foe.velocity.x
	
	return slide + relative_velocity
