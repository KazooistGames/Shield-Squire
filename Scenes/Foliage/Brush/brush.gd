extends Area2D

const inhabited_mask : Color = Color(1.0, 1.0, 1.0, 0.25)
const uninhabited_mask : Color = Color(1.0, 1.0, 1.0, 1.0)

@onready var sprite : Sprite2D = $Sprite2D
@onready var collider : CollisionShape2D = $CollisionShape2D

var linked_bushes : Array[Area2D] = []
var inhabitants : Array[CharacterBody2D] = []

func _ready():
	
	area_entered.connect(_handle_area_entered)
	area_exited.connect(_handle_area_exited)


func _handle_area_entered(area : Node2D):
	
	if area.collision_layer & 2048 >= 1:
		linked_bushes.append(area)
		
	var area_parent = area.get_parent()
	
	if not area_parent is CharacterBody2D:
		pass
		
	elif not area_parent.Concealments.has(self):
		sprite.modulate = inhabited_mask
		area_parent.Concealments.append(self)
		inhabitants.append(area_parent)
		
		for bush in linked_bushes:
			bush._handle_area_entered(area)
			
	
func _handle_area_exited(area : Node2D):
	
	var area_parent = area.get_parent()
	
	if not area_parent is CharacterBody2D:
		pass
		
	elif area_parent.Concealments.has(self):
		area_parent.Concealments.erase(self)
		inhabitants.erase(area_parent)
		
		if inhabitants.size() == 0:
			sprite.modulate = uninhabited_mask
		
		for bush in linked_bushes:
			bush._handle_area_exited(area)
