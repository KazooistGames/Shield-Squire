extends "res://Scenes/Guy/Personality/behaviours/behaviour.gd"

const swing_range = 20
const min_state_time = 5
const max_state_time = 15

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


func _physics_process(delta) -> void:
	
	swing_cooldown_timer += delta
	
	_determine_foe()
	Yielding = not Foe
	
	if Yielding:
		return
		
	state_timer += delta
	
	var early_completion = state_timer >= min_state_time and state_completed
	var timedout = state_timer >= max_state_time
	var disposition = Foe.global_position - personality.Me.global_position
	
	if early_completion or timedout:
		var next_state = calc_next_state()
		get_change_state(next_state)
		
	var in_range = disposition.length() <= swing_range
	var swing_ready = swing_cooldown_timer >= swing_cooldown_period
	
	if in_range and swing_ready:
		personality.Me.turn_toward(Foe)
		personality.Me.charge()
		state_completed = true
		swing_cooldown_timer = 0.0
		
	match state:
		
		State.charge:
			Desired_Coordinates = Foe.global_position
			swing_cooldown_period = 0.0
			
		State.flee:
			Desired_Coordinates = personality.Me.global_position - disposition.normalized() * 100
			swing_cooldown_period = 3.0
					
		State.wait:
			Desired_Coordinates = personality.Me.global_position
			swing_cooldown_period = 0.0
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


func _can_see_through_all_concealments(other_guy : CharacterBody2D) -> bool:
	
	for concealment in other_guy.Concealments:
		
		if concealment == null:
			continue
		elif not personality.Me.Concealments.has(concealment):
			return false
	
	return true
	
	
func calc_next_state():
	
	return randi_range(0, 2)
	
	
func get_change_state(new_state : State):
	print('_fight: ', new_state)
	state_timer = 0.0
	state_completed = false
	state = new_state
