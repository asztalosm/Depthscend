extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var oxygen = 1000
@export var speed = 250
@export var health = 70
@export var maxhealth = 70
@export var damage = 2
@export var hasdashcharm = true
@export var cantakedamage = true

#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D
@onready var swordhitbox = $SwordHitbox
@onready var attackcooldown = $AttackCooldown
@onready var attackprogress = $AttackProgress
@onready var attackcharge = $AttackChargeProgress
@onready var swordanimation = $SwordHitbox/CollisionShape2D/AnimatedSprite2D
@onready var dashnode = $Dash
@onready var dashtexture = $Dash/Guide
@onready var dashattackzone = $Dash/DashAttackZone
@onready var animatedsprite = $AnimatedSprite2D

var target = self.position
var inattackzone = []
var indashattackzone = []
var attacked = false
var accel = 35
var dir := Vector2()
var hasnavigationtarget = false # 4 órát veszítettem el az életemből és még a juiceba bele se számolta. NE TÖRÖLD KI
var charging = false
var dashing = false
var currentsprite = 0
var moveangle = 0

func _ready() -> void:
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)


func dash() -> void:
	$Dash/DashAttackZone/CollisionShape2D.position.y = -58
	indashattackzone.clear()
	swordhitbox.visible = true
	swordanimation.play()
	swordhitbox.rotate(swordhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
	dashnode.visible = false
	charging = false
	attackcharge.value = 0
	attackcharge.visible = false
	attacked = true
	dashing = true
	cantakedamage = false
	
	modulate.a = 0.5
	velocity += global_position.direction_to(get_global_mouse_position()) * speed * 2
	await get_tree().create_timer(0.5).timeout
	dashing = false
	swordhitbox.visible = false
	attackcooldown.start()
	var attackcooldowntween = get_tree().create_tween()
	attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
	await get_tree().create_timer(0.25).timeout
	indashattackzone.clear()
	modulate.a = 1
	cantakedamage = true
	$Dash/DashAttackZone/CollisionShape2D.position.y = 3000 # banish collisionshape to the shadow realm temporarily to clear the areas from the entered function
	
	
	

func _get_input():
	if get_meta("active") and !get_meta("isDead") and !dashing:
		var inputdir = Input.get_vector("kb_A", "kb_D", "kb_W", "kb_S")
		if inputdir != Vector2.ZERO:
			hasnavigationtarget = false
		velocity = inputdir * speed
		moveangle = rad_to_deg(inputdir.angle()) - 90
		if moveangle < 0:
			moveangle += 360
		if inputdir != Vector2(0,0):
			currentsprite = round(moveangle / 45)

func _input(event): # pathfinding + attack

	if event.is_action("kb_A") and get_meta("active") or event.is_action("kb_D") and get_meta("active") or event.is_action("kb_S") and get_meta("active") or event.is_action("kb_W") and get_meta("active"):
		navagent.target_position = position
	#stops pathfinding when WASD is pressed

	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"): #pf
		hasnavigationtarget = true
		target = get_global_mouse_position()
		navagent.target_position = target

	if event.is_action_pressed("rclick") and get_meta("active") and not get_meta("isDead") and !attacked:
		charging = true
		attackcharge.visible = true
		attackcharge.value = 0
		attackprogress.value = 0
		dashtexture.size.y = 0
		
	if event.is_action_released("rclick") and attackcharge.visible and !attacked:
		if attackcharge.value == 100 and hasdashcharm: #max charged attack with groundslam
			dash()
		else:
			swordanimation.frame = 0
			attackcharge.value = 0
			charging = false
			attackcharge.visible = false
			attacked = true
			swordhitbox.rotate(swordhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
			swordhitbox.visible = true
			swordanimation.play()
			attackcooldown.start()
			await get_tree().create_timer(0.2).timeout
			for i in inattackzone:
				if i.get_parent().cantakedamage:
					i.get_parent().health -= damage
			swordhitbox.visible = false
			var attackcooldowntween = get_tree().create_tween()
			attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
		




func _physics_process(_delta: float) -> void:
	if !dashing:
		velocity = Vector2.ZERO
		_get_input()
	if health > 0: # mozgás
		if attackcharge.value == 100: #charged attack szín
			attackcharge.modulate.r = 255
		else: attackcharge.modulate.r = 0.7
		dir = navagent.get_next_path_position() - global_position
		if !navagent.is_navigation_finished() and hasnavigationtarget:
			if dir.length_squared() > 1.0:
				dir = dir.normalized()
			if !navagent.is_target_reached():
				velocity = dir * speed
			if dir.length_squared() > 1:
				var angletocursor = rad_to_deg(self.get_angle_to(navagent.get_next_path_position())) - 90
				if angletocursor < 0:
					angletocursor += 360
				currentsprite = round(angletocursor / 45)
		animatedsprite.frame = currentsprite
		move_and_slide()
		
		
		if charging:
			attackcharge.value += 2
			dashtexture.size.y = 0
			if attackcharge.value == 100 and hasdashcharm:
				dashnode.visible = true
				dashnode.rotate(dashnode.get_angle_to(get_global_mouse_position()) +0.5*PI)
				var dashsizetween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
				dashsizetween.tween_property(dashtexture, "size:y", 96, 0.4)
		if self.get_meta("active"):
			attackcooldown.wait_time = 0.3
		else:
			attackcooldown.wait_time = 0.5
	else: #megöli a játékost
		visible = false
		set_meta("active", false)
		set_meta("isDead", true)


func _on_attack_cooldown_timeout():
	attacked = false
	# for i in inattackzone:
	# 	AttackSprite.play()
	# 	await get_tree().create_timer(0.3).timeout
	# 	AttackSprite.frame = 0
	# 	i.get_parent().health -= 2

func _on_auto_attack_range_area_entered(area: Area2D) -> void: #attackrangeben lévő enemyk sebzése
	inattackzone.append(area)

func _on_auto_attack_range_area_exited(area: Area2D) -> void:
	inattackzone.erase(area)


func _on_dash_attack_zone_area_entered(area: Area2D) -> void:
	indashattackzone.append(area)
	for i in indashattackzone:
		if i.get_parent().cantakedamage:
			indashattackzone.erase(i)
			i.get_parent().health -= damage * 1.5
