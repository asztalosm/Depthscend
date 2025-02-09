extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var speed = 200
@export var health = 30
@export var maxhealth = 70
@export var damage = 2
var accel = 35
var dir := Vector2()
#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D 
@onready var projectile := $Projectile as Area2D
var target = self.position # hack hogy ne mozduljon el a karakter spawnoláskol és menjen el 0,0-ra


func _input(event):
	#movement
	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"):
		target = get_global_mouse_position()
		navagent.target_position = target

func _physics_process(_delta: float) -> void:
	if health > 0:
		dir = navagent.get_next_path_position() - global_position
		if dir.length_squared() > 1.0:
			dir = dir.normalized()
		velocity = velocity.lerp(dir * speed, accel * _delta)
		move_and_slide()
	else:
		visible = false
		set_meta("active", false)
		set_meta("isDead", true)
