extends CharacterBody2D


export (int) var speed = 200

var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("click"):
		velocity.x += 1
	velocity = velocity.normalized() * speed
	
func physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
