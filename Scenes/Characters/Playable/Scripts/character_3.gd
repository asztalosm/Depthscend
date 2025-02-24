extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var oxygen = 1000
@export var speed = 225
@export var health = 70
@export var maxhealth = 70
@export var damage = 2
@export var cantakedamage = true
#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D 
@onready var projectile := $Projectile as Area2D
@onready var healhitbox := $HealRangeHitbox
@onready var healprogbar := $HealRange/TextureProgressBar
@onready var healcooldown := $HealCooldown
@onready var animatedsprite := $AnimatedSprite2D

var accel = 35
var dir := Vector2()
var target = self.position # hack hogy ne mozduljon el a karakter spawnoláskol és ne menjen el 0,0-ra
var healhitboxchars = []
var currentsprite = 0
var moveangle = 0
var hasnavigationtarget = false



func tweenhealth():
	healprogbar.value = 0
	await get_tree().create_timer(1).timeout
	var healtween = get_tree().create_tween()
	healtween.tween_property(healprogbar, "value", 100, healcooldown.wait_time-1.5)


func _ready() -> void:
	tweenhealth()
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func _get_input(): #mivel nem találtam jobb megoldást erre a funkcióra ami csak akkor lenne meghívva amikor inputot ad a játékos ezért ez ennyiben marad
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
		
	#movement
	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"):
		hasnavigationtarget = true
		target = get_global_mouse_position()
		navagent.target_position = target

	
func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	_get_input()
	
	if health > 0:
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
	else:
		visible = false
		set_meta("active", false)
		set_meta("isDead", true)
		

func _on_heal_cooldown_timeout() -> void:
	if !get_meta("isDead"):
		for characters in healhitboxchars:
			if characters.maxhealth > characters.health and !characters.get_meta("isDead"):
				characters.health += 1
		if self.maxhealth > self.health:
			self.health += 1
		tweenhealth()
	

func _on_heal_range_hitbox_area_entered(area: Area2D) -> void:
	healhitboxchars.append(area.get_parent())


func _on_heal_range_hitbox_area_exited(area: Area2D) -> void:
	healhitboxchars.erase(area.get_parent())
