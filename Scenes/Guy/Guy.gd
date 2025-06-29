extends CharacterBody2D

const pixels_per_run_frame := 5
const default_run_frames_per_second := 15

enum State{
	ready,
	charging,
	attacking,
	recovering
}

@export var state : State = State.ready
@export var speed := 75.0
@export var run_direction := 0.0
@export var current_frame : Sprite2D = null

@onready var sprites : AnimatedSprite2D = $AnimatedSprite2D

var acceleration := 480.0
var charge_timer := 0.0
var cooldown_timer := 0.0

var cooldown_to_chare_ratio := 0.5
var charge_timer_max := 1.5


func _process(delta : float) -> void:
	
	if current_frame:
		print(current_frame.atlas._is_pixel_opaque(0,0))
	
	if state == State.charging:
		charge_timer += delta
		
		if charge_timer >= charge_timer_max:
			charge_timer = charge_timer_max 
			release()
		
	elif state == State.recovering:
		cooldown_timer -= delta
		
		if cooldown_timer <= 0:
			ready()
		

func _physics_process(delta : float) -> void:
	
	if is_on_floor():
		_apply_acceleration(delta)

	else:
		velocity.y += 980 * delta
		
	move_and_slide()
	

func _apply_acceleration(delta: float):
	
	var speed_ratio: float = clamp(1.0 - abs(velocity.x/speed) / 2.0, 0.0, 1.0)
	var real_accel : float = acceleration * speed_ratio
	var target_speed = run_direction * speed if state == State.ready else 0
	velocity.x = move_toward(velocity.x, target_speed, real_accel * delta)
	

func jump() -> bool:
	
	if not is_on_floor():
		return false

	velocity.y = -360
	return true
		

func crouch() -> bool:
	
	return false
	
	
func charge() -> bool:

	if state == State.ready:
		state = State.charging
		cooldown_timer = 0.0
		return true
	else:
		return false

	
func release() -> bool:
	
	if state == State.charging:
		state = State.attacking
		cooldown_timer = charge_timer * cooldown_to_chare_ratio
		sprites.play()
		return true
	else:
		return false


func recover() -> bool:
	
	if state == State.attacking:
		state = State.recovering
		charge_timer = 0.0
		sprites.play()
		return true
	else:
		return false


func ready() -> bool:
	
	if state == State.recovering:
		state = State.ready
		sprites.play()	
		return true
	else:
		return false
		
		
func check_frame_collision(shape : Shape2D) -> bool:
	
	var bounds : Vector2 = shape.get_rect().size
	
	for x in range(bounds.x):
		
		if current_frame.is_pixel_opaque(Vector2(x, 0)):
			return true
	
	return false
	
