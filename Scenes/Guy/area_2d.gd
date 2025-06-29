extends Area2D


@onready var parent : CharacterBody2D = get_parent()

var guys_marked_for_hit : Array[CharacterBody2D] = []
var guys_marked_for_parry : Array[CharacterBody2D] = []


func _process(delta : float) -> void:
	
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
				var other_guy : CharacterBody2D = area.get_parent()
				
				if guys_marked_for_parry.has(other_guy):
					pass
				elif other_guy.state == other_guy.State.attacking:
					guys_marked_for_parry.append(other_guy)
				elif guys_marked_for_hit.has(other_guy):
					pass
				else:
					guys_marked_for_hit.append(other_guy)
					
					
func _process_recovering(delta : float) -> void:
	
	for guy in guys_marked_for_hit:
		print(guy, ' was just hit')
		
	guys_marked_for_hit.clear()
		
	for guy in guys_marked_for_parry:
		print(guy, ' was just parried')
		
	guys_marked_for_parry.clear()
