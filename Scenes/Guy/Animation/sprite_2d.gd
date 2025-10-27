extends Sprite2D
const pixels_per_run_frame := 5
const default_run_frames_per_second := 12

@export var playback_speed = 1.0

@onready var parent : Guy = get_parent()

var active_state : Node = null
var sprite_dimensions := Vector2(24,24)

signal looped(String)
signal finished(String)

	
func _physics_process(delta: float) -> void:
	if active_state != null:	#get exact frame texture based on active state and offset coordinates
		texture = active_state.sprite_sheet
		sprite_dimensions = active_state.texture_size
		var x = sprite_dimensions.x * active_state.current_frame_index
		var y = 0
		var w = sprite_dimensions.x
		var h = sprite_dimensions.y
		region_rect = Rect2(x, y, w, h)


func _handle_state_finished():
	finished.emit(active_state.name)
	
	
func _handle_state_looped():
	looped.emit(active_state.name)
	

func set_animation_state(state_name : StringName) -> void:
	var new_state : Node = find_child(state_name, false)
	if new_state == null:
		print(name + " animation state not found: " + state_name)
		return
	elif new_state == active_state:
		return
	elif active_state:
		active_state.playing = false
		active_state.finished.disconnect(_handle_state_finished)
		active_state.looped.disconnect(_handle_state_looped)
	
	active_state = new_state 
	active_state.play()
	active_state.finished.connect(_handle_state_finished)
	active_state.looped.connect(_handle_state_looped)
