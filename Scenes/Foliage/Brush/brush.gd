extends Area2D


func _ready():
	
	area_entered.connect(_handle_area_entered)
	area_entered.connect(_handle_area_exited)


func _handle_area_entered(body : Node2D):

	if not body is CharacterBody2D:
		pass
	else:
		body.Concealments.append(self)
	
	
func _handle_area_exited(body : Node2D):
	
	if not body is CharacterBody2D:
		pass
	elif body.Concealments.has(self):
		body.Concealments.append(self)
