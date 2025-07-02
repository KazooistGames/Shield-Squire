
extends Node2D

const bottom_section_index := 0
const limb_section_index := 1
const top_section_index := 3

@export var Height := 0 :
	get():
		return Height
	set(value):	
		if _grow_tree(value):
			Height = value

@onready var trunk_segment_prefab := preload("res://Scenes/Foliage/Trunk_Segment/Trunk_Segment.tscn")

var trunk_segments : Array[StaticBody2D] = []


func _ready():

	if Height == 0:
		Height = randi_range(3, 5)
		
		
func _grow_tree(height) -> bool:
	
	for segment in trunk_segments:
		segment.queue_free()
		
	trunk_segments.clear()
	
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
		section_index = randi_range(2, 2)
	
	var new_segment : StaticBody2D = trunk_segment_prefab.instantiate()
	new_segment.Section_Index = section_index
	add_child(new_segment)	

	var vertical_offset = -24 * trunk_segments.size()
	new_segment.position = Vector2(0, vertical_offset)
	trunk_segments.append(new_segment)	
	
	return true
