extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var oxygen = 1000
@export var speed = 250
@export var health = 70
@export var maxhealth = 70
@export var damage = 4
var accel = 35
var dir := Vector2()
#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D
var target = self.position
var inattackzone = []
@onready var AttackSprite := $AutoAttackRange/AnimatedSprite2D as AnimatedSprite2D
@onready var swordhitbox = $SwordHitbox
@onready var attackcooldown = $AttackCooldown
var attacked = false
@onready var attackprogress = $AttackProgress
var currentsprite = 0
@onready var animatedsprite = $AnimatedSprite2D
var moveangle = 0



func _get_input():
	if get_meta("active") and !get_meta("isDead"):
		var inputdir = Input.get_vector("kb_A", "kb_D", "kb_W", "kb_S")
		velocity = inputdir * speed
		moveangle = rad_to_deg(inputdir.angle()) - 90
		if moveangle < 0:
			moveangle += 360 
		if inputdir != Vector2(0,0):
			currentsprite = round(moveangle / 45)

func _input(event):
	if event.is_action("kb_A") or event.is_action("kb_D") or event.is_action("kb_S") or event.is_action("kb_W") and get_meta("active"):
		navagent.target_position = position


	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"):
		target = get_global_mouse_position()
		navagent.target_position = target
	if event.is_action_pressed("rclick") and get_meta("active") and not get_meta("isDead"): #attack override
		if !attacked:
			attackprogress.value = 0
			swordhitbox.visible = true
			attacked = true
			swordhitbox.rotate(swordhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
			attackcooldown.start()
			AttackSprite.play()
			await get_tree().create_timer(0.3).timeout
			for i in inattackzone:
				i.get_parent().health -= damage
			swordhitbox.visible = false
			AttackSprite.frame = 0
			var attackcooldowntween = get_tree().create_tween()
			attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
		else:
			pass
		
func _physics_process(_delta: float) -> void:
	if health > 0: # mozgás
		dir = navagent.get_next_path_position() - global_position
		if !get_meta("active") and navagent.is_target_reached():
			velocity = Vector2(0,0)
		_get_input()
		if !navagent.is_navigation_finished():
			if dir.length_squared() > 1.0:
				dir = dir.normalized()
			if !navagent.is_target_reached():
				velocity = velocity.lerp(dir * speed, accel * _delta * 1.75)
			if dir.length_squared() > 1:
				var angletocursor = rad_to_deg(self.get_angle_to(navagent.get_next_path_position())) - 90
				if angletocursor < 0:
					angletocursor += 360 
				currentsprite = round(angletocursor / 45)
		animatedsprite.frame = currentsprite
		
		# 	dir = navagent.get_next_path_position() - global_position
		# 	if dir.length_squared() > 1.0:
		# 		dir = dir.normalized()
		# 		velocity = velocity.lerp(dir * speed, accel *_delta) * 1.75
		move_and_slide()
		
		if self.get_meta("active"):
			attackcooldown.wait_time = 1.5
		else:
			attackcooldown.wait_time = 2.25
	else: #megöli a játékost
		visible = false
		set_meta("active", false)
		set_meta("isDead", true)

	


func _on_attack_cooldown_timeout():
	attacked = false

func _on_auto_attack_range_area_entered(area: Area2D) -> void: #attackrangeben lévő enemyk sebzése
	inattackzone.append(area)
	
func _on_auto_attack_range_area_exited(area: Area2D) -> void:
	inattackzone.erase(area)
