extends AnimatedSprite2D

const pixels_per_run_frame := 5
const default_run_frames_per_second := 15

@export var run_direction := 0.0

@onready var parent : CharacterBody2D = get_parent()



func _ready() -> void:
	
	play()
	animation_looped.connect(_handle_animation_looped)


func _process(delta : float) -> void:
	
	
	if not parent.is_on_floor():
		animation = 'stance'
	elif parent.velocity.x == 0:
		animation = 'stance'
	elif parent.velocity.x != 0:
		animation = 'run'
		flip_h = parent.velocity.x > 0
		
	if animation == 'run':
		speed_scale = abs(parent.velocity.x) / (pixels_per_run_frame  * default_run_frames_per_second)
	else:
		speed_scale = 1.0
		



func _handle_animation_looped():
	
	if animation == 'swing':
		animation = 'stance'
