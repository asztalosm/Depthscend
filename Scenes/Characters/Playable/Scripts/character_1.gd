extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var speed = 250
@export var health = 10
@export var maxhealth = 70
@export var damage = 4
var accel = 35
var dir := Vector2()
#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D
var target = self.position
var inattackzone = []
@onready var AttackSprite := $AutoAttackRange/AnimatedSprite2D as AnimatedSprite2D



func _input(event):
	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"):
		target = get_global_mouse_position()
		navagent.target_position = target
		


func _physics_process(_delta: float) -> void:
	if health > 0: # mozgás
		dir = navagent.get_next_path_position() - global_position
		if dir.length_squared() > 1.0:
			dir = dir.normalized()
		velocity = velocity.lerp(dir * speed, accel * _delta)
		move_and_slide()
	else: #megöli a játékost
		visible = false
		set_meta("active", false)
		set_meta("isDead", true)

	


func _on_attack_cooldown_timeout():
	for i in inattackzone:
		AttackSprite.play()
		await get_tree().create_timer(0.3).timeout
		AttackSprite.frame = 0
		i.get_parent().health -= damage

func _on_auto_attack_range_area_entered(area: Area2D) -> void: #attackrangeben lévő enemyk sebzése
	inattackzone.append(area)
	
func _on_auto_attack_range_area_exited(area: Area2D) -> void:
	inattackzone.erase(area)
