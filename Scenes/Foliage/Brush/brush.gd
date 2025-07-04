extends Area2D

const inhabited_mask : Color = Color(1.0, 1.0, 1.0, 0.25)
const uninhabited_mask : Color = Color(1.0, 1.0, 1.0, 1.0)

@onready var sprite : Sprite2D = $Sprite2D
@onready var collider : CollisionShape2D = $CollisionShape2D


func _ready():
	
	area_entered.connect(_handle_area_entered)
	area_exited.connect(_handle_area_exited)


func _handle_area_entered(area : Node2D):
	
	var parent = area.get_parent()
	
	if not parent is CharacterBody2D:
		pass
	else:
		sprite.modulate = inhabited_mask
		parent.Concealments.append(self)
	
	
func _handle_area_exited(area : Node2D):
	
	var parent = area.get_parent()
	
	if not parent is CharacterBody2D:
		pass
		
	elif parent.Concealments.has(self):
		parent.Concealments.erase(self)
		
		if get_overlapping_areas().size() ==0:
			sprite.modulate = uninhabited_mask
