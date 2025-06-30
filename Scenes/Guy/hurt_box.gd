extends Area2D

@export var Position_Offset = -1

@onready var parent : CharacterBody2D = get_parent()
@onready var collider : CollisionShape2D = $CollisionShape2D


func _process(delta : float) -> void:
	
	position.x = Position_Offset * parent.facing_direction
