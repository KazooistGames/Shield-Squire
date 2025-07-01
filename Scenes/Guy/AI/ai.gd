extends Node2D

@onready var personality : Area2D = $Personality
@onready var navigation : Node2D = $Navigation
@onready var me : CharacterBody2D = get_parent()


func _ready():
	
	personality.Me = me
	navigation.Me = me


func _physics_process(delta : float) -> void:
	
	
	if not inside_deadband():
		personality.Deadbanded = false
		me.left_right = sign(personality.Desired_Coordinates.x - global_position.x)
		
	elif not personality.Deadbanded:
		personality.Deadbanded = true
		me.left_right = 0
		#personality.deadband_enter_action()


func inside_deadband() -> bool:
	
	var disposition : Vector2 = personality.Desired_Coordinates - global_position
	
	if me.is_on_floor():
		return disposition.length() < personality.destination_deadband
	else:
		return abs(disposition.x) < personality.destination_deadband
		
