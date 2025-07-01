extends "res://Scenes/Guy/AI/Personality/behaviour.gd"

@export var Foe : CharacterBody2D = null
		

func _physics_process(delta) -> void:
	
	_determine_foe()
	
	if Foe:
		_tango_with_foe()
	else:
		pass


func _tango_with_foe():
	
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
