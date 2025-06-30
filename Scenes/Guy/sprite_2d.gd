extends Sprite2D

const sprite_dimensions := Vector2(24,24)

const pixels_per_run_frame := 5
const default_run_frames_per_second := 15

@onready var parent : CharacterBody2D = get_parent()

var active_state : Node2D = null

signal looped(String)
signal finished(String)


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
				flip_h = parent.velocity.x > 0
				
		parent.State.charging:
			set_animation_state('charge')
			
		parent.State.attacking:
			set_animation_state('attack')

		parent.State.recovering:
			set_animation_state('recover')


func set_animation_state(state_name : StringName) -> void:
	
	var new_state : Node = find_child(state_name, false)
	
	if new_state == null or new_state == active_state:
		return
	
	if active_state:
		active_state.playing = false
		active_state.finished.disconnect(_handle_state_finished)
		active_state.looped.disconnect(_handle_state_looped)
	
	active_state = new_state 
	active_state.play()
	active_state.finished.connect(_handle_state_finished)
	active_state.looped.connect(_handle_state_looped)


func _handle_state_finished():
	
	finished.emit(active_state.name)
	
	if active_state.name == 'attack':
		parent.recover()
	
	
func _handle_state_looped():
	
	looped.emit(active_state.name)
	
	
