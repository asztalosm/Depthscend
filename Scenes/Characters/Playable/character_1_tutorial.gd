extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var oxygen = 1000
@export var speed = 250
@export var health = 70
@export var maxhealth = 70
@export var damage = 4
@export var maxdamage = 6
@export var canwasdmove = false # tutorial variable
@export var canmousemove = true
@export var canmouseattack = false
@export var basicrightclick = true #csak azért van itt, hogy az első ütés legyen meg, ezután charged attack cseréli majd le
@export var hasgroundslamcharm = false
@export var charms = [
	["hasgroundslamcharm", false, load("res://Textures/Groundslam.png")],
	["none", true, null]
]
@export var cantakedamage = true
@export var guistats = [
	[load("res://Textures/damage.png"), damage],
	[load("res://Textures/damage_2.png"), maxdamage],
	[load("res://Textures/speed.png"), speed],
]

#változók amik a karakterben vannak jelen
@onready var slashanimation = $SwordHitbox/AnimatedSprite2D
@onready var groundslamhitbox = $GroundSlamHitbox
@onready var navagent := $NavigationAgent2D as NavigationAgent2D
@onready var swordhitbox = $SwordHitbox
@onready var attackcooldown = $AttackCooldown
@onready var attackprogress = $AttackProgress
@onready var animatedsprite = $AnimatedSprite2D
@onready var attackcharge = $AttackChargeProgress
@onready var groundslamtexture = $GroundSlamHitbox/CollisionShape2D/PointLight2D
@onready var abilitycdprogress = $AbilityChargeProgress
@onready var abilitycd = $AbilityCooldown

#lokális változók
var ACCEL = 35
var dir := Vector2()
var target = self.position
var inattackzone = []
var attacked = false
var currentsprite = 0
var moveangle = 0
var charging = false
var groundslamattackzone = []
var hasnavigationtarget = false
var shadermaterial : ShaderMaterial





func _ready() -> void:
	attackprogress.visible = false
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func _get_input():
	if get_meta("active") and !get_meta("isDead") and canwasdmove:
		var inputdir = Input.get_vector("kb_A", "kb_D", "kb_W", "kb_S")
		if inputdir != Vector2.ZERO:
			hasnavigationtarget = false
		velocity = inputdir * speed
		moveangle = rad_to_deg(inputdir.angle()) - 90
		if moveangle < 0:
			moveangle += 360
		if inputdir != Vector2(0,0):
			currentsprite = round(moveangle / 45)

func groundslam() -> void:
	abilitycdprogress.value = 0
	abilitycdprogress.visible = true
	abilitycd.start()
	charging = false
	attackcharge.visible = false
	attacked = true
	groundslamhitbox.rotate(groundslamhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
	groundslamhitbox.visible = true
	groundslamtexture.reparent(get_parent().get_parent())
	groundslamtexture.color = Color(1,1,1, 0.2)
	var groundslamtween = get_tree().create_tween()
	groundslamtween.tween_property(groundslamtexture, "color:a", 1, 0.3)
	await get_tree().create_timer(0.35).timeout
	for i in groundslamattackzone:
		i.get_parent().health -= roundi(damage + 4)
	var groundslamtweeninvis = get_tree().create_tween()
	groundslamtweeninvis.tween_property(groundslamtexture, "color:a", 0, 2)
	attackcooldown.wait_time += 2
	attackcooldown.start()
	var attackcooldowntween = get_tree().create_tween()
	attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
	var abilitycooldowntween = get_tree().create_tween()
	abilitycooldowntween.tween_property(abilitycdprogress, "value", 100, abilitycd.time_left)
	await get_tree().create_timer(2).timeout
	groundslamtexture.reparent(get_node("GroundSlamHitbox/CollisionShape2D"))
	groundslamtexture.position = Vector2.ZERO
	groundslamhitbox.visible = false

func _input(event):
	if event.is_action("kb_A") and get_meta("active") or event.is_action("kb_D") and get_meta("active") or event.is_action("kb_S") and get_meta("active") or event.is_action("kb_W") and get_meta("active"):
		if canwasdmove:
			navagent.target_position = position

	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead") and canmousemove:
		hasnavigationtarget = true
		target = get_global_mouse_position()
		navagent.target_position = target
		
	
	if basicrightclick:
		if event.is_action_pressed("rclick") and get_meta("active") and not get_meta("isDead") and canmouseattack: #attack override
			if !attacked:
				attackprogress.value = 0
				swordhitbox.visible = true
				attacked = true
				swordhitbox.rotate(swordhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
				attackcooldown.start()
				slashanimation.play()
				await get_tree().create_timer(0.3).timeout
				for i in inattackzone:
					i.get_parent().health -= damage
					i.get_parent().get_node("effects").play("blink")
				swordhitbox.visible = false
				var attackcooldowntween = get_tree().create_tween()
				attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
	else:
		if event.is_action_pressed("rclick") and get_meta("active") and not get_meta("isDead") and !attacked: #attack override
			charging = true
			attackcharge.visible = true
			attackcharge.value = 0
			attackprogress.value = 0
		if event.is_action_released("rclick") and get_meta("active") and not get_meta("isDead") and attackcharge.visible and !attacked:
			if attackcharge.value == 100 and hasgroundslamcharm and abilitycdprogress.visible == false: #max charged attack with groundslam
				groundslam()
			else: #attack without groundslam
				swordhitbox.set_deferred("disabled", false)
				slashanimation.frame = 0
				charging = false
				attackcharge.visible = false
				attacked = true
				swordhitbox.rotate(swordhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
				swordhitbox.visible = true
				slashanimation.play()
				attackcooldown.start()
				
				await get_tree().create_timer(0.3).timeout
				for i in inattackzone:
					if i.get_parent().get_node_or_null("effects") != null:
						i.get_parent().get_node("effects").play("blink")
					i.get_parent().health -= roundi(damage + attackcharge.value / 50)
				swordhitbox.visible = false
				var attackcooldowntween = get_tree().create_tween()
				attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
				swordhitbox.set_deferred("disabled", true)
		if !self.get_meta("active"): #resets the characters attack progress when the player changes characters
			charging = false
			attackcharge.visible = false
func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	_get_input()
	if health > 0: # ha él a karakter
		dir = navagent.get_next_path_position() - global_position

		if attackcharge.value == 100:
			attackcharge.modulate.r = 255
		else: attackcharge.modulate.r = 0.7

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
		position = round(position)
		if charging:
			attackcharge.value += 0.5
		
		if self.get_meta("active"):
			attackcooldown.wait_time = 2.5
		elif !self.get_meta("active"):
			attackcooldown.wait_time = 3
	else: #megöli a játékost
		visible = false
		set_meta("active", false)
		set_meta("isDead", true)

	


func _on_attack_cooldown_timeout():
	attacked = false

func _on_auto_attack_range_area_entered(_area: Area2D) -> void: #attackrangeben lévő enemyk sebzése
	pass
	
func _on_auto_attack_range_area_exited(_area: Area2D) -> void:
	pass


func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	inattackzone.append(area)


func _on_sword_hitbox_area_exited(area: Area2D) -> void:
	inattackzone.erase(area)
 
func _on_ground_slam_hitbox_area_entered(area: Area2D) -> void:
	groundslamattackzone.append(area)

func _on_ground_slam_hitbox_area_exited(area: Area2D) -> void:
	groundslamattackzone.erase(area)


func _on_ability_cooldown_timeout() -> void:
	abilitycdprogress.visible = false
