extends Camera2D

@export var player : CharacterBody2D = null

@export var target_position := Vector2(0, 0)
@export var reposition_speed := 10


func _process(delta : float) -> void:

	_movement_inputs(delta)
	_combat_inputs(delta)

func _movement_inputs(_delta : float) -> void:

	if Input.is_action_pressed("Left") and Input.is_action_pressed("Right"):
		player.run_direction = 0
	elif Input.is_action_pressed("Right"):
		player.run_direction = 1
	elif Input.is_action_pressed("Left"):
		player.run_direction = -1
	else:
		player.run_direction = 0

	if Input.is_action_just_pressed("Up"):
		player.jump()
	elif Input.is_action_just_pressed("Down"):
		player.crouch()
		

func _combat_inputs(_delta : float) -> void:
	
	if Input.is_action_just_pressed("Attack"):
		player.attack()

func _physics_process(delta):

	var offset_from_target : Vector2 = target_position - position
	var curve = pow(offset_from_target.length() / 10.0, 2)
	position = position.move_toward(target_position, reposition_speed * curve * delta)
