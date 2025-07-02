extends StaticBody2D

const sprite_dimensions = Vector2(24, 24)

enum Section {
	canopy = 0,
	trunk = 1,
	branch = 2,
	stump = 3
}

@export var Section_Index = 0 :
	get:
		return Section_Index
	set(value):
		if set_section(value):
			Section_Index = value

@onready var sprite : Sprite2D = $Sprite2D
@onready var collider : CollisionShape2D = $CollisionShape2D

var limb : Node2D = null

func set_section(index):
	
	if limb:
		limb.queue_free()
	
	if index * sprite_dimensions.y >= $Sprite2D.texture.get_size().y:
		return false
		
	var x = 0
	var y = sprite_dimensions.y * index
	var w = sprite_dimensions.x
	var h = sprite_dimensions.y
	$Sprite2D.region_rect = Rect2(x, y, w, h)
	$Sprite2D.flip_h = randf() > 0.5
	$CollisionShape2D.disabled = index == Section.canopy 
	
	if index == Section.branch:
		_attach_limb()
	
	return true
	

func _attach_limb():	
	
	var limb_prefab : PackedScene = load("res://Scenes/Foliage/Limb.tscn")
	limb = limb_prefab.instantiate()
	limb.Direction = -1 if $Sprite2D.flip_h else 1
	add_child(limb)
	var x_offset = -sprite_dimensions.x if $Sprite2D.flip_h else sprite_dimensions.x
	limb.position = Vector2(x_offset, 0)
