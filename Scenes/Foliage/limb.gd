
extends Node2D

const bottom_section_index := 0
const branch_section_index := 1
const top_section_index := 3

@export var Length := 0 :
	get():
		return Length
	set(value):	
		if _grow_branch(value):
			Length = value

@onready var branch_segment_prefab := preload("res://Scenes/Foliage/Branch_Segment/Branch_Segment.tscn")

var branch_segments : Array[StaticBody2D] = []


func _ready():

	if Length == 0:
		Length = randi_range(1, 3)
		
		
func _grow_branch(height) -> bool:
	
	for segment in branch_segments:
		segment.queue_free()
		
	branch_segments.clear()
	
	for index in range(height):		
		var top : bool = index == (height - 1)
		var bottom : bool = index == 0
		_generate_segment(top, bottom)
	
	return true
	
	
func _generate_segment(top : bool, bottom : bool) -> bool:
	
	var section_index : int
		
	if top and bottom:
		section_index = 0 if randf() > 0.5 else 3
	
	elif top:
		section_index = 0
	
	elif bottom:
		section_index = 3
	
	else:
		section_index = randi_range(1, 2)
	
	var new_segment : StaticBody2D = branch_segment_prefab.instantiate()
	new_segment.Section_Index = section_index
	add_child(new_segment)	
	
	var horizontal_offset = 24 * branch_segments.size() * sign(position.x)
	new_segment.position = Vector2(horizontal_offset, 0)
	branch_segments.append(new_segment)	
	
	return true
