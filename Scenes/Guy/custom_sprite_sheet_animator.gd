extends Node2D



@export var sprite_sheet : CompressedTexture2D = null
@export var playing := false
@export var frames_per_second := 3
@export var current_frame_index := 0
@export var first_frame_index := 0
@export var last_frame_index := 0
@export var looping := true


var frame_timer := 0.0

signal looped
signal finished


func _process(delta : float) -> void:
	
	_process_sheet_animation(delta)
	

func _process_sheet_animation(delta : float) -> void:
	
	if not playing:
		frame_timer = 0
		current_frame_index = first_frame_index
		return
		
	frame_timer += delta
	var frame_period : float = 1.0 / frames_per_second
	
	if frame_timer >= frame_period:
		frame_timer -= frame_period
		_get_next_frame()
	

func _get_next_frame():
	
	if current_frame_index != last_frame_index:
		current_frame_index += 1
	elif looping:
		current_frame_index = first_frame_index
		looped.emit()
	else:
		current_frame_index = first_frame_index
		playing = false
		finished.emit()

		
		
