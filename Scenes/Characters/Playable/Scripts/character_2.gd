extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var oxygen = 1000
@export var speed = 250
@export var health = 70
@export var maxhealth = 70
@export var damage = 2
@export var basedamage = 2
@export var maxdamage = 3
@export var cantakedamage = true
@export var guistats = [
	[load("res://Textures/damage.png"), damage],
	[load("res://Textures/damage_2.png"), maxdamage],
	[load("res://Textures/speed.png"), speed],
]

@export var charms = [
	["hasdashcharm", false, load("res://Textures/Dash.png")],
	["hassoultearcharm", false, load("res://Textures/Soultear.png")],
	["none", true, null]
]

#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent = $NavigationAgent2D
@onready var swordhitbox = $SwordHitbox
@onready var attackcooldown = $AttackCooldown
@onready var attackprogress = $AttackProgress
@onready var attackcharge = $AttackChargeProgress
@onready var swordanimation = $SwordHitbox/CollisionShape2D/AnimatedSprite2D
@onready var dashnode = $Dash
@onready var dashtexture = $Dash/Guide
@onready var dashattackzone = $Dash/DashAttackZone
@onready var animatedsprite = $AnimatedSprite2D
@onready var abilitycd = $AbilityCooldown
@onready var abilitycdprogress = $AbilityChargeProgress
@onready var soulfragment = $SoulFragment

var autoattackzone = []
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
var ismoving = false

func _ready() -> void:
	soulfragment.get_node("CollisionShape2D").set_deferred("enabled", false)
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)


func dash() -> void: #basically ugyanaz mint egy normális attack csak van közbe más mozgás meg hitbox
	abilitycd.start()
	abilitycdprogress.value = 0
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
	var abilitycdtween = get_tree().create_tween()
	abilitycdtween.tween_property(abilitycdprogress, "value", 100, abilitycd.time_left)
	$Dash/DashAttackZone/CollisionShape2D.position.y = 30000 # banish collisionshape to the shadow realm temporarily to clear the areas from the entered function
	
func soultear() -> void: #soul tear attack
	abilitycd.start()
	abilitycdprogress.value = 0
	charging = false
	swordhitbox.visible = true
	swordhitbox.rotate(swordhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
	attackcharge.visible = false
	attackcharge.value = 0
	swordanimation.play()
	attacked = true
	await get_tree().create_timer(0.2).timeout
	attackcooldown.start()
	var attackcooldowntween = get_tree().create_tween()
	attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
	swordhitbox.visible = false
	for enemy in inattackzone:
		if enemy.get_parent().cantakedamage == true:
			if enemy.get_parent().health - damage*2 <= 0:
				var temporaryposition = enemy.get_parent().position
				soulspread(temporaryposition)
				$SoulSpreadAnimation.visible = true
				$SoulSpreadAnimation.global_position = enemy.global_position
				enemy.get_parent().health -= damage*2
				$SoulSpreadAnimation.play("default")
			else:
				enemy.get_parent().health -= damage*2
				enemy.get_parent().get_node("effects").play("blink")
	

func soulspread(temporaryposition) -> void: #soul tear attack létrehoz 4 soul fragmentet ami healel karaktert vagy sebez enemyt
	await get_tree().create_timer(2.3).timeout
	var soulfraglist = []
	for soulfragmentnum in range(4):
		var tempsoulfragment = soulfragment.duplicate()
		tempsoulfragment.name = "SoulFragment" + str(soulfragmentnum)
		soulfraglist.append(tempsoulfragment)
	for fragments in soulfraglist:
		fragments.global_position = temporaryposition + Vector2(randf_range(-100,100),randf_range(-100,100))
		#ide majd még kell csinálni egy rekurzív functiont ami megnézi, hogy falban van-e az i
		fragments.visible = true
		fragments.script = load("res://Scenes/Characters/Playable/soul_fragment.gd")
		fragments.get_node("CollisionShape2D").disabled = false
		get_parent().get_parent().add_child(fragments)
	var abilitycdtween = get_tree().create_tween()
	abilitycdtween.tween_property(abilitycdprogress, "value", 100, abilitycd.wait_time)

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

	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"): #pathfinding
		hasnavigationtarget = true
		target = get_global_mouse_position()
		navagent.target_position = target

	if event.is_action_pressed("rclick") and get_meta("active") and not get_meta("isDead") and !attacked: #attackcharge
		charging = true
		damage = basedamage
		attackcharge.visible = true
		attackcharge.value = 0
		attackprogress.value = 0
		dashtexture.size.y = 0
		if charms[0][1]:
			abilitycd.wait_time = 5
		elif charms[1][1]:
			abilitycd.wait_time = 10
		else:
			abilitycd.wait_time = 1
	if event.is_action_released("rclick") and attackcharge.visible and !attacked and get_meta("active") and !get_meta("isDead"):
		swordhitbox.monitoring = true
		if attackcharge.value == 100 and charms[0][1] and abilitycd.time_left == 0: #max charged attack with groundslam
			dash()
			abilitycdprogress.visible = true
		if attackcharge.value == 100 and charms[1][1] and abilitycd.time_left == 0: #soultear cooldown
			soultear()
			abilitycdprogress.visible = true
			var abilitycdtween = get_tree().create_tween()
			abilitycdtween.tween_property(abilitycdprogress, "value", 100, abilitycd.wait_time)
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
			$AttackSound.play()
			await get_tree().create_timer(0.2).timeout
			
			for i in inattackzone:
				if i.get_parent().cantakedamage:
					i.get_parent().health -= damage
					i.get_parent().get_node("effects").play("blink")
			swordhitbox.visible = false
			var attackcooldowntween = get_tree().create_tween()
			attackcooldowntween.set_parallel(true)
			attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
		swordhitbox.monitoring = false
		
	if !get_meta("active"):
		charging = false
		swordanimation.frame = 0
		attacked = false
		swordhitbox.visible = false
		dashnode.visible = false
		attackcharge.visible = false

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
				currentsprite = roundi(angletocursor / 45)
		if velocity != Vector2(0,0):
			animatedsprite.play(str("walk", int(currentsprite)))
		else:
			animatedsprite.stop()
		move_and_slide()
		
		
		if charging:
			attackcharge.value += 2
			dashtexture.size.y = 0
			if attackcharge.value == 100 and charms[0][1] and abilitycd.time_left == 0:
				dashnode.visible = true
				dashnode.rotate(dashnode.get_angle_to(get_global_mouse_position()) +0.5*PI)
				var dashsizetween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
				dashsizetween.tween_property(dashtexture, "size:y", 96, 0.4)
			elif attackcharge.value == 100:
				damage = maxdamage
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
	autoattackzone.append(area)

func _on_auto_attack_range_area_exited(area: Area2D) -> void:
	autoattackzone.erase(area)


func _on_dash_attack_zone_area_entered(area: Area2D) -> void:
	if charms[0][1] and dashing:
		indashattackzone.append(area)
		for i in indashattackzone:
			if i.get_parent().cantakedamage and dashing and get_node_or_null(get_path_to(i)) != null:
				indashattackzone.erase(i)
				i.get_parent().health -= damage
				i.get_parent().get_node("effects").play("blink")


func _on_ability_cooldown_timeout() -> void:
	abilitycdprogress.visible = false
	$AbilityCDSound.play()


func _on_soul_fragment_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.


func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	inattackzone.append(area)


func _on_sword_hitbox_area_exited(area: Area2D) -> void:
	inattackzone.erase(area)
