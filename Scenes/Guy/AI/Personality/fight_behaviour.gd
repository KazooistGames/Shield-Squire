extends "res://Scenes/Guy/AI/Personality/behaviour.gd"

@export var Foe : CharacterBody2D = null


func _physics_process(delta):
	
	if Foe:
		Desired_Coordinates = Foe.global_position
		
	else:
		Desired_Coordinates = area.global_position
		for body in area.detected_bodies():
			
			if body is CharacterBody2D:
				Foe = body
	
