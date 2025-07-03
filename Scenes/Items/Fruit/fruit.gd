extends RigidBody2D

const energy := 50

func _ready():
	
	freeze = true
	

func smack(impulse : Vector2):
	
	freeze = false
	var direction = Vector2(randf(), randf()).normalized()
	var magnitude = 10
	
	apply_central_impulse(impulse)
	apply_torque_impulse(impulse.length())
	
	
func consume(guy : CharacterBody2D):
	
	guy.Strength += energy
	queue_free()
