extends StaticBody2D

const sprite_dimensions = Vector2(24, 24)

@export var Section_Index = 0 :
	get:
		return Section_Index
	set(value):
		if set_section(value):
			Section_Index = value


@onready var sprite : Sprite2D = $Sprite2D
@onready var collider : CollisionShape2D = $CollisionShape2D


func set_section(index):
	
	if index * sprite_dimensions.y >= $Sprite2D.texture.get_size().y:
		return false
		
	var x = 0
	var y = sprite_dimensions.y * index
	var w = sprite_dimensions.x
	var h = sprite_dimensions.y
	$Sprite2D.region_rect = Rect2(x, y, w, h)
	$Sprite2D.flip_h = randf() > 0.5
	
	$CollisionShape2D.disabled = index == 0 
	return true
