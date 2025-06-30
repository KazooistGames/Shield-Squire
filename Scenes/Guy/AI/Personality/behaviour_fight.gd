extends "res://Scenes/Guy/AI/Personality/behaviour.gd"

@export var Foe : CharacterBody2D = null


func _process(delta) -> void:
	
	if not Foe:
		pass
	elif not parent.Deadbanded:
		pass
	elif parent.Me.state == parent.Me.State.ready:
		parent.Me.charge()

func _physics_process(delta) -> void:
	
	if Foe:
		Desired_Coordinates = Foe.global_position
		
	else:
		Desired_Coordinates = parent.global_position
		
		for body in parent.detected_bodies():
			
			if body is CharacterBody2D:
				Foe = body
	


func deadband_enter_action():
	parent.Me.charge()


func deadband_exit_action():
	print('fight deadband exited')
	pass
