extends CharacterBody2D
#itt ezek az exportok globális változók lesznek amiket el lehet érni más scriptekből
@export var speed = 200
@export var health = 65
@export var maxhealth = 70
@export var damage = 2
var accel = 35
var dir := Vector2()
#változó ami akkor jön létre amikor létrejön a karakter
@onready var navagent := $NavigationAgent2D as NavigationAgent2D 
@onready var projectile := $Projectile as Area2D
var target = self.position # hack hogy ne mozduljon el a karakter spawnoláskol és ne menjen el 0,0-ra
@onready var healhitbox := $HealRangeHitbox
var healhitboxchars = []
@onready var healprogbar := $HealRange/TextureProgressBar
@onready var healcooldown := $HealCooldown
@onready var animatedsprite := $AnimatedSprite2D
var currentsprite = 0

func tweenhealth():
	healprogbar.value = 0
	await get_tree().create_timer(1).timeout
	var healtween = get_tree().create_tween()
	healtween.tween_property(healprogbar, "value", 100, healcooldown.wait_time-1.5)


func _ready() -> void:
	tweenhealth()

func _input(event):
	#movement
	if event.is_action_pressed("click") and get_meta("active") and not get_meta("isDead"):
		target = get_global_mouse_position()
		navagent.target_position = target
		
	if event.is_action_pressed("changesprite"):
		if animatedsprite.frame != 7:
			animatedsprite.frame += 1
		else:
			animatedsprite.frame = 0

func _physics_process(_delta: float) -> void:
	if health > 0:
		dir = navagent.get_next_path_position() - global_position
		navagent.target_desired_distance = 30
		if dir.length_squared() > 1.0:
			dir = dir.normalized()
		if !navagent.is_target_reached():
			velocity = velocity.lerp(dir * speed, accel * _delta)
			move_and_slide()
		if dir.length_squared() > 1:
			var angletocursor = rad_to_deg(self.get_angle_to(navagent.get_next_path_position())) - 90
			if angletocursor < 0:
				angletocursor += 360 
			currentsprite = round(angletocursor / 45)
			animatedsprite.frame = currentsprite
	else:
		visible = false
		set_meta("active", false)
		set_meta("isDead", true)
		

func _on_heal_cooldown_timeout() -> void:
	for characters in healhitboxchars:
		if characters.maxhealth > characters.health:
			characters.health += 1
	if self.maxhealth > self.health:
		self.health += 1
	tweenhealth()
	

func _on_heal_range_hitbox_area_entered(area: Area2D) -> void:
	healhitboxchars.append(area.get_parent())


func _on_heal_range_hitbox_area_exited(area: Area2D) -> void:
	healhitboxchars.erase(area.get_parent())
