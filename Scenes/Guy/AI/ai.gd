extends Node2D

const destination_deadband = 24
@export var Deadbanded := false

@onready var personality : Area2D = $Personality
@onready var navigation : Node2D = $Navigation
@onready var guy = get_parent()


func _ready():
	
	personality.Detection_Exceptions.append(guy)


func _process(delta):
	
	var disposition : Vector2 = personality.Desired_Coordinates - global_position
	
	if disposition.length() > destination_deadband:
		Deadbanded = false
		guy.run_direction = sign(personality.Desired_Coordinates.x - global_position.x)
	else:
		Deadbanded = true
		guy.run_direction = 0
