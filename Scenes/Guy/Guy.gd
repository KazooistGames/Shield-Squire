extends CharacterBody2D

const duck_duration := 0.1
const coyote_period := 0.20
const acceleration := 480
const top_speed := 60
const charge_timer_max := 1.0
const charge_timer_min := 0.10
const energy_recharge_rate := 25.0

enum State{
	ready,
	charging,
	attacking,
	recovering,
	sliding,
	dead
}

@export var Team := 0
@export var state : State = State.ready
@export var HP := 100
@export var Energy := 100.0
@export var left_right := 0
@export var Concealments : Array[Area2D] = []

@onready var sprite : Sprite2D = $Sprite2D
@onready var hitbox : Area2D = $hitBox
@onready var hurtbox : Area2D = $hurtBox

var speed := 60.0
var facing_direction := 1
var facing_locked := false

var jump_height = 36

var charge_timer := 0.0
var charge_marked_for_release := false #used when guy attempts to swing before min charge is met

var cooldown_timer := 0.0
var cooldown_to_charge_ratio := 1.0

var coyote_timer := 0.0

var duck_debounce := 0.0

signal died
signal jumped
signal fell

func _ready() -> void:
	
	hitbox.landed_hit.connect(_handle_hit)
	hitbox.parried.connect(_handle_parry)
	
	
func _physics_process(delta : float) -> void:
	
	if left_right == 0 and is_on_floor() and state == State.ready:
		Energy += delta * energy_recharge_rate
	
	Energy = clampf(Energy, 0, 100)
	
	if left_right != 0 and not facing_locked:
		facing_direction = left_right	
		
	facing_locked = state != State.ready and state != State.charging
	
	if duck_debounce < duck_duration:
		duck_debounce += delta
		collision_mask = 1
		
	else:
		collision_mask = 17
		
	if not is_on_floor():
		velocity.y += 980 * delta	
	
	
	_process_velocity(delta)	
	move_and_slide()		
	_coyote(delta)		
	_process_state(delta)


func _process_velocity(delta : float) -> void:
	speed = top_speed * lerpf(0.5, 1.0, Energy/100)
	cooldown_to_charge_ratio = lerpf(2.0, 1.0, Energy/100)
	
	var speed_ratio: float = clamp(1.0 - abs(velocity.x/speed), 0.5, 1.0)
	var real_accel : float = acceleration * speed_ratio
	
	if state == State.ready:
		var target_speed = left_right * speed
		velocity.x = move_toward(velocity.x, target_speed, real_accel * delta)
		
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, real_accel * delta)
	
	
func _process_state(delta : float) -> void:
	
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


func _coyote(delta):
	
	if is_on_floor():
		coyote_timer = 0.0
		return
		
	elif coyote_timer == 0.0:
		fell.emit()		
		
	coyote_timer += delta
		

func jump() -> bool:
	
	if coyote_timer >= coyote_period:
		return false
	elif state == State.dead:
		return false

	coyote_timer = coyote_period
	sap(10)
	velocity.y = -sqrt(jump_height * 1960)
	jumped.emit()
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
		var charge_power = charge_timer / charge_timer_max
		sap(roundi(charge_power * 25))
		var impulse = Vector2(facing_direction, 0) * charge_power * 100
		shove(impulse)
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
	

func _handle_hit(guy : CharacterBody2D):
	
	var power = sqrt(charge_timer/charge_timer_max) * 120
	var impulse = Vector2(facing_direction, 0) * power
	guy.shove(impulse)
	guy.damage(charge_timer/charge_timer_max * 100)
	
	
func _handle_parry(guy : CharacterBody2D):
	
	var impulse = Vector2(facing_direction, 0) * 96
	guy.shove(impulse)

		
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

	
func shove(impulse : Vector2) -> void:
	
	if sign(velocity.x) == sign(impulse.x):
		velocity.x += impulse.x
	else:
		velocity.x = impulse.x
		
	#if sign(velocity.y) == sign(impulse.y):
		#velocity.y += impulse.y
	#else:
		#velocity.y = impulse.y
	
	
	
func damage(value : int) -> void:
	
	HP -= value
	
	if HP <= 0:
		died.emit()
		state = State.dead


func is_facing(object : Node2D) -> bool:
	
	var disposition = object.global_position - global_position
	return sign(disposition.x) == sign(facing_direction)
	
	
func turn_toward(object : Node2D):
	
	if facing_locked:
		return
	else:
		facing_locked = true
		
	var x_disposition = object.global_position.x - global_position.x
	facing_direction = sign(x_disposition)
	
	
func sap(value : float):
	
	if Energy <= 0:
		damage(value)
		
	elif value > Energy:
		var diff = value - Energy
		Energy = 0
		damage(diff)
		
	else:
		Energy -= value


func interact():
	
	var interactable_bodies = hurtbox.get_overlapping_bodies()
	
	for body in interactable_bodies:
		
		if body.collision_layer & 512 >= 1:
			body.use(self)
			return
	
	
