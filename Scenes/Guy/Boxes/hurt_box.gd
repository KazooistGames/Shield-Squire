extends Area2D

@export var Position_Offset : Vector2 = Vector2(8, 0)

@onready var parent : CharacterBody2D = get_parent()
@onready var collider : CollisionShape2D = $CollisionShape2D


func _process(delta : float) -> void:
	position = Position_Offset
	position.x *= parent.facing_direction
