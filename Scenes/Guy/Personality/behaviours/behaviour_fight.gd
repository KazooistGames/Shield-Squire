extends "res://Scenes/Guy/Personality/behaviours/behaviour.gd"

@export var Foe : CharacterBody2D = null
		

func _physics_process(delta) -> void:
	
	if Foe:
		_battle_with_foe()
	else:
		Yielding = true
	
	_determine_foe()


func _battle_with_foe():
	
	if personality.Deadbanded:
		personality.Me.charge()
		

func _determine_foe():
	
	if not Foe:
		Desired_Coordinates = personality.global_position
		
		for body in personality.detected_bodies():
			
			if body is CharacterBody2D:
				Foe = body
				
	elif not personality.detected_bodies().has(Foe):
		Foe = null
		Desired_Coordinates = personality.global_position
		
	else:
		Desired_Coordinates = Foe.global_position
