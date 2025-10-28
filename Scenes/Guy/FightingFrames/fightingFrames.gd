@tool
class_name FightingFrames
extends Sprite2D
const pixels_per_run_frame := 5
const default_run_frames_per_second := 12

@export var sprite_sheet : CompressedTexture2D = null
@export var texture_size : Vector2i = Vector2i(24,24)
@export var playing := false
@export var playback_speed = 1.0
@export var frames_per_second := 3
@export var frame_timer := 0.0
@export var first_frame_index := 0
@export var last_frame_index := 0
@export var current_frame_index := 0
@export var looping := true

@export var hitbox_disabled : bool = false
@export var hitbox_radius : float = 6.0
@export var hitbox_height : float = 24.0
@export var hitbox_rotation : float = 0.0
@export var hitbox_positions : Array[Vector2] = []
@onready var hitbox_collider : CollisionShape2D = $hitbox/CollisionShape2D

@export var hurtbox_radius : float = 6.0
@export var hurtbox_height : float = 24.0
@export var hurtbox_rotation : float = 0.0
@export var hurtbox_positions : Array[Vector2] = []
@onready var hurtbox_collider : CollisionShape2D = $hurtbox/CollisionShape2D

@export var param_node : FrameParams :
	get:
		return param_node
	set(value):
		param_node = value
		if value != null:
			load_params(param_node)			

signal started()
signal looped()
signal finished()
	
func _physics_process(delta: float) -> void:
	hitbox_collider.disabled = hitbox_disabled or not playing
	hitbox_collider.shape.radius = hitbox_radius
	hitbox_collider.shape.height = hitbox_height
	hitbox_collider.rotation_degrees = hitbox_rotation
	
	hurtbox_collider.shape.radius = hurtbox_radius
	hurtbox_collider.shape.height = hurtbox_height
	hurtbox_collider.rotation_degrees = hurtbox_rotation
	if not playing:
		frame_timer = 0
	else:
		frame_timer += delta
		var frame_period : float = 1.0 / frames_per_second
		if frame_timer >= frame_period:
			frame_timer -= frame_period
			_get_next_frame()		

	first_frame_index = clampf(first_frame_index, 0, last_frame_index)
	last_frame_index = clampf(last_frame_index, first_frame_index, last_frame_index)
	current_frame_index = clampi(current_frame_index, first_frame_index, last_frame_index)
	_render_current_frame()


func _get_next_frame():
	if current_frame_index < last_frame_index:
		current_frame_index += 1	
	elif looping:
		current_frame_index = first_frame_index
		looped.emit()	
	else:
		current_frame_index = first_frame_index
		playing = false
		finished.emit()


func _render_current_frame():
	if sprite_sheet != null:	#get exact frame texture based on active state and offset coordinates
		texture = sprite_sheet
		var x = texture_size.x * current_frame_index
		var y = 0
		var w = texture_size.x
		var h = texture_size.y
		region_rect = Rect2(x, y, w, h)
	
	var frame_number : int = current_frame_index - first_frame_index
	var x_dir = -1 if flip_h else 1
	var y_dir = -1 if flip_v else 1
	if frame_number < hitbox_positions.size():
		hitbox_collider.position.x = hitbox_positions[frame_number].x * x_dir
		hitbox_collider.position.y = hitbox_positions[frame_number].y * y_dir
	if frame_number < hurtbox_positions.size():
		hurtbox_collider.position.x = hurtbox_positions[frame_number].x * x_dir
		hurtbox_collider.position.y = hurtbox_positions[frame_number].y * y_dir
		
		
func play():
	started.emit()
	texture = sprite_sheet
	current_frame_index = first_frame_index
	playing = true
	
func stop():
	finished.emit()
	playing = false
	current_frame_index = first_frame_index
	
	
func load_params(params):
	if not params is FrameParams:
		return
	sprite_sheet = params.sprite_sheet
	texture_size = params.texture_size
	playing = params.playing
	frames_per_second  = params.frames_per_second
	first_frame_index  = params.first_frame_index
	last_frame_index  = params.last_frame_index
	looping  = params.looping
	hitbox_disabled = params.hitbox_disabled
	hitbox_radius = params.hitbox_radius
	hitbox_height = params.hitbox_height
	hitbox_rotation = params.hitbox_rotation
	hitbox_positions = params.hitbox_positions
	hurtbox_radius = params.hurtbox_radius
	hurtbox_height = params.hurtbox_height
	hurtbox_rotation = params.hurtbox_rotation
	hurtbox_positions = params.hurtbox_positions
