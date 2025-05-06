extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var oxygen = 1000
@export var speed = 250
@export var health = 70
@export var maxhealth = 70
@export var basedamage = 4
@export var damage = 4
@export var maxdamage = 6
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

#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D
@onready var swordhitbox = $SwordHitbox
@onready var attackcooldown = $AttackCooldown
@onready var attackprogress = $AttackProgress
@onready var animatedsprite = $AnimatedSprite2D
@onready var attackcharge = $AttackChargeProgress
@onready var slashanimation = $SwordHitbox/AnimatedSprite2D as AnimatedSprite2D
@onready var groundslamhitbox = $GroundSlamHitbox
@onready var abilitychargeprogress = $AbilityChargeProgress
@onready var abilitycd = $AbilityCooldown
@onready var attacksound = $AttackSound

var currentsprite = 0
var moveangle = 0
var charging = false
var groundslamattackzone = []
var hasnavigationtarget = false
var target = self.position
var inattackzone = []
var attacked = false
var accel = 35
var dir := Vector2()
var ismoving = false


func _ready() -> void:
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func groundslam() -> void:
	abilitycd.start()
	abilitychargeprogress.value = 0
	abilitychargeprogress.visible = true
	charging = false
	attackcharge.visible = false
	attacked = true
	groundslamhitbox.rotate(groundslamhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
	groundslamhitbox.visible = true
	await get_tree().create_timer(0.3).timeout
	for i in groundslamattackzone:
		i.get_parent().health -= int(roundi(damage + 4))
		i.get_parent().get_node("effects").play("blink")
	groundslamhitbox.visible = false
	var abilitychargetween = get_tree().create_tween()
	abilitychargetween.tween_property(abilitychargeprogress, "value", 100, abilitycd.time_left)
	var attackcooldowntween = get_tree().create_tween()
	attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)


func _get_input():
	if get_meta("active") and !get_meta("isDead"):
		var inputdir = Input.get_vector("kb_A", "kb_D", "kb_W", "kb_S") #rotation and movement based on WASD input
		if inputdir != Vector2.ZERO:
			hasnavigationtarget = false
		velocity = inputdir * speed
		moveangle = rad_to_deg(inputdir.angle()) - 90
		if moveangle < 0:
			moveangle += 360 
		if inputdir != Vector2(0,0):
			currentsprite = round(moveangle / 45) #sprite change based on direction

func _input(event):
	if event.is_action("kb_A") and get_meta("active") or event.is_action("kb_D") and get_meta("active") or event.is_action("kb_S") and get_meta("active") or event.is_action("kb_W") and get_meta("active"):
		navagent.target_position = position  # cancels the pathfinding when WASD buttons are pressed


	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"):
		hasnavigationtarget = true
		target = get_global_mouse_position()
		navagent.target_position = target #pathfinding setup
		
	if event.is_action_pressed("rclick") and get_meta("active") and not get_meta("isDead") and !attacked: #attack override
		charging = true
		damage = basedamage
		attackcharge.visible = true
		attackcharge.value = 0
		attackprogress.value = 0
		
	if event.is_action_released("rclick") and get_meta("active") and (not get_meta("isDead")) and attackcharge.visible and !attacked:
		attackcooldown.start()
		if attackcharge.value == 100 and charms[0][1] and abilitychargeprogress.visible == false: #max charged attack
			groundslam()
			
		else: #not abilty attack
			slashanimation.frame = 0
			charging = false
			attackcharge.visible = false
			attacked = true
			swordhitbox.rotate(swordhitbox.get_angle_to(get_global_mouse_position()) +0.5*PI)
			swordhitbox.visible = true
			slashanimation.play()
			attacksound.play()
			damage = round(damage + (attackcharge.value / 50))
			await get_tree().create_timer(0.15).timeout
			for i in inattackzone:
				i.get_parent().get_node("effects").play("blink")
				i.get_parent().health -= int(damage) #jelenleg nem túl szép dolog TODO ezt fixelni, hogy maxdamagere scaleljen, ez szerintem majd release után lesz csak
			await get_tree().create_timer(0.15).timeout
			swordhitbox.visible = false
			var attackcooldowntween = get_tree().create_tween()
			attackcooldowntween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)
	if !self.get_meta("active"):
		charging = false
		attackcharge.visible = false



func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO # resets velocity to 0 so the character doesnt move randomly
	_get_input()
	if health > 0: # mozgás
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
				currentsprite = roundi(angletocursor / 45) #all characters have a walk8 animation that matches up with the walk0 animation so the debugger stops bitching
		if velocity != Vector2(0,0):
			animatedsprite.play(str("walk", int(currentsprite)))
		else:
			animatedsprite.stop()
		move_and_slide()
		position = round(position)
		
		#charge
		if charging:
			attackcharge.value += 0.5
		
		
		if self.get_meta("active"):
			attackcooldown.wait_time = 2.5
		elif not get_meta("active"):
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
	abilitychargeprogress.visible = false
	$AbilityCDSound.play()
