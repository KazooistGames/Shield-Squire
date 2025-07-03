extends CharacterBody2D

const pixels_per_run_frame := 5
const default_run_frames_per_second := 15
const duck_duration := 0.2

enum State{
	ready,
	charging,
	attacking,
	recovering,
	sliding
}

@export var state : State = State.ready
@export var HP := 100
@export var Strength := 100.0
@export var left_right := 0

@onready var sprite : Sprite2D = $Sprite2D
@onready var hitBox : Area2D = $hitBox
@onready var hurtBox : Area2D = $hurtBox

var speed := 75.0
var facing_direction := 1
var facing_locked := false
var acceleration := 480.0
var jump_height = 75

var charge_timer := 0.0
var charge_timer_max := 1.0
var charge_timer_min := 0.25
var charge_marked_for_release := false #used when guy attempts to swing before min charge is met

var cooldown_timer := 0.0
var cooldown_to_charge_ratio := 1.0

var duck_debounce := 0.0

signal died


func _ready() -> void:
	
	hitBox.landed_hit.connect(_handle_hit)
	hitBox.parried.connect(_handle_parry)
	

func _process(delta : float) -> void:
	
	facing_locked = state == State.attacking or state == State.sliding
	
	if left_right != 0 and not facing_locked:
		facing_direction = left_right
		
	if duck_debounce < duck_duration:
		duck_debounce += delta
		collision_mask = 1
	else:
		collision_mask = 17

	match state:
		
		State.charging:
			charge_timer += delta
			
			if charge_timer >= charge_timer_max:
				charge_timer = charge_timer_max 
				release()
				
			elif charge_marked_for_release:
				release()
		
		State.recovering:
			cooldown_timer -= delta
			
			if cooldown_timer <= 0:
				ready()
				
		State.sliding:
			 
			if velocity.x == 0:
				state = State.ready
		

func _physics_process(delta : float) -> void:
	
	if not is_on_floor():
		velocity.y += 980 * delta
		
	var speed_ratio: float = clamp(1.0 - abs(velocity.x/speed), 0.5, 1.0)
	var real_accel : float = acceleration * speed_ratio
	var target_speed = left_right * speed if state == State.ready else 0
	velocity.x = move_toward(velocity.x, target_speed, real_accel * delta)
	move_and_slide()
	

func jump(height : int = 36) -> bool:
	
	if not is_on_floor():
		return false

	sap(1)
	velocity.y = -sqrt(height * 1960)
	return true
	

func duck() -> bool:
	duck_debounce = 0.0
	return false
	
	
func charge() -> bool:

	if state == State.ready:
		state = State.charging
		cooldown_timer = 0.0
		charge_timer = 0.0
		return true
		
	else:
		return false

	
func release() -> bool:
	
	if not state == State.charging:
		return false
		
	elif charge_timer < charge_timer_min:
		charge_marked_for_release = true
		return false
		
	else:
		charge_marked_for_release = false
		state = State.attacking
		cooldown_timer = charge_timer * cooldown_to_charge_ratio
		sap(1)
		return true


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
		
		
func check_sprite_collision(coordinates : Vector2, bounds : Vector2, offset : Vector2 = Vector2.ZERO) -> bool:
	
	var disposition : Vector2 = coordinates - global_position
	var pixel_coord : Vector2
	var bound_coord : Vector2 = Vector2.ZERO
	
	for y in range(-bounds.y / 2.0, bounds.y / 2.0):
		bound_coord.y = y
		for x in range(-bounds.x / 2.0, bounds.x / 2.0):
			bound_coord.x = x
			pixel_coord = disposition + bound_coord + offset
			if sprite.is_pixel_opaque(pixel_coord):
				return true
		
	return false
	

func _handle_hit(guy : CharacterBody2D):
	
	var disposition = guy.global_position - global_position
	var power = sqrt(charge_timer/charge_timer_max) * 100
	var impulse = disposition.normalized() * power
	guy.shove(impulse)
	guy.damage(charge_timer/charge_timer_max * 100)
	
	
func _handle_parry(guy : CharacterBody2D):
	
	var disposition = guy.global_position - global_position
	var impulse = disposition.normalized() * 100
	guy.shove(impulse)
	guy.cooldown_timer = max(charge_timer * 2.0, guy.cooldown_timer)

	
func shove(impulse : Vector2) -> void:
	
	if sign(velocity.x) == sign(impulse.x):
		velocity.x += impulse.x
	else:
		velocity.x = impulse.x
		
	if sign(velocity.y) == sign(impulse.y):
		velocity.y += impulse.y
	else:
		velocity.y = impulse.y
	
	
	
func damage(value : int) -> void:
	
	HP -= value
	
	if HP <= 0:
		died.emit()


func is_facing(object : Node2D) -> bool:
	
	var disposition = object.global_position - global_position
	return sign(disposition.x) == sign(facing_direction)
	
	
func turn_around():
	
	facing_direction *= -1
	
	
func sap(value : float):
	
	if Strength <= 0:
		damage(value)
		
	elif value > Strength:
		var diff = value - Strength
		Strength = 0
		damage(diff)
		
	else:
		Strength -= value
