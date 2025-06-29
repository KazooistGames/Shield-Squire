extends CharacterBody2D


enum State{
	stance,
	run,
	aeriel,
	attack
}

const pixels_per_run_frame := 5
const default_run_frames_per_second := 15

@export var speed := 75.0
@export var run_direction := 0.0

#@onready var sprites : AnimatedSprite2D = $AnimatedSprite2D

var acceleration := 480




func _physics_process(delta : float) -> void:
	
	if is_on_floor():
		_accelerate_run(delta)
		#velocity.y = 0
	else:
		velocity.y += 980 * delta
		
	#print(velocity)
	move_and_slide()
	

func _accelerate_run(delta: float):
	
	var speed_ratio: float = clamp(1.0 - abs(velocity.x/speed) / 2.0, 0.0, 1.0)
	var real_accel : float = acceleration * speed_ratio
	velocity.x = move_toward(velocity.x, run_direction * speed, real_accel * delta)
	


func is_trying_to_turn_around() -> bool:
	
	var changing_dir : bool = sign(velocity.x) != sign(run_direction)
	var slow : bool = abs(velocity.x) < speed / 5
	return false
	return changing_dir and slow
	

func jump() -> bool:
	
	if not is_on_floor():
		return false
		
	velocity.y = -360
	return true
		

func crouch() -> bool:
	
	return false
	
	
func attack() -> bool:
	
	#sprites.animation = 'swing'
	return true
