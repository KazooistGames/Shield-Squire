extends Node

@export var Desired_Coordinates := Vector2.ZERO
@export var Active := true
@export var Yielding := false
@export var Priority := 0
@export var Max_Seconds := 0
@export var Fallback : Node = null

@onready var area : Area2D = get_parent()

var time_active := 0.0


func _process(delta):
	
	time_active += delta
	
