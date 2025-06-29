extends Sprite2D

const sprite_dimensions := Vector2(24,24)

const pixels_per_run_frame := 5
const default_run_frames_per_second := 15

@export var run_direction := 0.

@onready var parent : CharacterBody2D = get_parent()

var active_state : Node2D = null


func _ready() -> void:
	
	set_animation_state('stance')
	

func _process(delta : float) -> void:
	
	_determine_active_state()
	_determine_active_frame_texture()
	

func _determine_active_frame_texture() -> void:
	
	texture = active_state.sprite_sheet
	var x = sprite_dimensions.x * active_state.current_frame_index
	var y = 0
	var w = sprite_dimensions.x
	var h = sprite_dimensions.y
	region_rect = Rect2(x, y, w, h)


func _determine_active_state() -> void:
	
	match(parent.state):
	
		parent.State.ready:
			
			if not parent.is_on_floor():
				set_animation_state('stance')
			elif parent.velocity.x == 0:
				set_animation_state('stance')
			else:
				set_animation_state('run')
				
		parent.State.charging:
			set_animation_state('charge')
			
		parent.State.attacking:
			set_animation_state('attack')

			
		parent.State.recovering:
			set_animation_state('recover')


func set_animation_state(state_name : StringName) -> void:
	
	var new_state : Node = find_child(state_name, false)
	
	if new_state == null:
		return
	
	if active_state:
		active_state.playing = false
	
	active_state = new_state 
	active_state.playing = true


		
