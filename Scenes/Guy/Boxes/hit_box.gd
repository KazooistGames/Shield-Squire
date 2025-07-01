extends Area2D

@export var Position_Offset = 8

@onready var parent : CharacterBody2D = get_parent()
@onready var collider : CollisionShape2D = $CollisionShape2D

var guys_marked_for_hit : Array[CharacterBody2D] = []
var guys_marked_for_parry : Array[CharacterBody2D] = []

signal parried(CharacterBody2D)
signal landed_hit(CharacterBody2D)


func _process(delta : float) -> void:
	
	position.x = Position_Offset * parent.facing_direction
	
	match parent.state:
		
		parent.State.attacking:
			_process_attacking(delta)
			
		parent.State.recovering:
			_process_recovering(delta)		
								
		_:
			pass
			

func _process_attacking(delta : float) -> void:
	
		var colliding_areas : Array[Area2D] = get_overlapping_areas()	
				
		for area in colliding_areas:
			var object = area.get_parent()
			
			if not parent.is_facing(object):
				pass
			elif object is CharacterBody2D:
				_handle_guy_overlap(object, area)

					
func _process_recovering(delta : float) -> void:
	
	
	for guy in guys_marked_for_hit:
		
		if guy.check_sprite_collision(global_position, collider.shape.size):
			landed_hit.emit(guy)
		
	guys_marked_for_hit.clear()
		
	for guy in guys_marked_for_parry:
		parried.emit(guy)
		
	guys_marked_for_parry.clear()


func _handle_guy_overlap(other_guy : CharacterBody2D, object_area : Area2D) -> void:
	
		if guys_marked_for_parry.has(other_guy):
			pass
			
		elif other_guy.state == other_guy.State.attacking and object_area.collision_layer == 8:
			guys_marked_for_parry.append(other_guy)
			
			if guys_marked_for_hit.has(other_guy):
				guys_marked_for_hit.erase(other_guy)
			
		elif guys_marked_for_hit.has(other_guy):
			pass
			
		elif object_area.collision_layer == 4:
			guys_marked_for_hit.append(other_guy)
	


	
	
