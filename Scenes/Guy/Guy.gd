extends CharacterBody2D

const pixels_per_run_frame := 5
const default_run_frames_per_second := 15

enum State{
	ready,
	charging,
	attacking,
	recovering,
	sliding
}

@export var state : State = State.ready
@export var speed := 75.0
@export var run_direction := 0.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var area : Area2D = $Area2D


var acceleration := 480.0
var charge_timer := 0.0
var cooldown_timer := 0.0

var cooldown_to_chare_ratio := 0.5
var charge_timer_max := 1.0


func _ready() -> void:
	
	area.hit.connect(_handle_hit)
	area.parried.connect(_handle_parry)
	

func _process(delta : float) -> void:
	
	match state:
		
		State.charging:
			charge_timer += delta
			
			if charge_timer >= charge_timer_max:
				charge_timer = charge_timer_max 
				release()
		
		State.recovering:
			cooldown_timer -= delta
			
			if cooldown_timer <= 0:
				ready()
				
		State.sliding:
			 
			if velocity.length() == 0:
				state = State.ready
		

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
		return true
	else:
		return false


func recover() -> bool:
	
	if state == State.attacking:
		state = State.recovering
		return true
	else:
		return false


func ready() -> bool:
	
	if state == State.recovering:
		state = State.ready
		charge_timer = 0.0
		return true
	else:
		return false
		
		
func check_sprite_collision(coordinates : Vector2, bounds : Vector2) -> bool:
	
	var offset : Vector2 = coordinates - global_position
	
	for y in range(-bounds.y / 2.0, bounds.y / 2.0):
		
		for x in range(-bounds.x / 2.0, bounds.x / 2.0):

			if sprite.is_pixel_opaque(Vector2(offset.x + x, offset.y + y)):
				return true
		
	return false
	

func _handle_hit(guy : CharacterBody2D):
	
	var disposition = guy.global_position - global_position
	var impulse = disposition.normalized() * sqrt(charge_timer) * 100
	guy.shove(impulse)
	
	
func _handle_parry(guy : CharacterBody2D):
	
	pass

	
func shove(impulse : Vector2) -> void:
	
	velocity += impulse
	state = State.sliding
