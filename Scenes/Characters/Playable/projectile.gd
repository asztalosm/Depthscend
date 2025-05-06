extends StaticBody2D
@export var speed = 500
@export var bounces = 0
@export var damage = 0
@export var inattackzone = []
@export var active = false
var maxdamage = 4
var minspeed = 725
var autoangle = false
var angle = Vector2.ZERO
var inwall = false
var projectiletween : Tween
var nearenemy = []
var attackchargetime = 2
var inexplosionarea = []
var exploded = true
@onready var texture = $TextureRect
@onready var enemyfinder = $EnemyFinder
@onready var charging = get_parent().charging
@onready var attackchargeprogress = get_parent().get_node("AttackChargeProgress")
@onready var attackprogress = get_parent().get_node("AttackProgress")
@onready var attackcooldown = get_parent().get_node("AttackCooldown")
@onready var explosionarea = $ExplosionArea
@onready var defaulthitbox = $Area2D #this is also used for balllightning but enlarged
@onready var lightningcooldown = $BallLightningCooldown

func charmcheck(): #charmok alapján beállítja a változókat
	scale = Vector2(2,2)
	speed = 750
	damage = 2
	maxdamage = 3
	defaulthitbox.scale = Vector2(1,1)
	bounces = 0
	if get_parent().charms[0][1]:
		texture.texture = load("res://Sprites/ricochet.png")
		get_parent().charms[1][1] = false
		get_parent().charms[2][1] = false
		attackcooldown.wait_time = 3.5
		bounces = 5
		autoangle = false
		enemyfinder.monitoring = true
	if get_parent().charms[2][1]:
		damage = 4
		maxdamage = 8
		get_parent().charms[0][1] = false
		get_parent().charms[1][1] = false
		bounces = 0
		texture.texture = load("res://Sprites/explosiveorb.png")
		attackcooldown.wait_time = 4.5
	if get_parent().charms[1][1]:
		defaulthitbox.scale = Vector2(3,3)
		minspeed = 625
		damage = 1
		maxdamage = 2
		speed = 650
		attackcooldown.wait_time = 5
		get_parent().charms[0][1] = false
		get_parent().charms[2][1] = false
		bounces = INF
		autoangle = false
		texture.texture = load("res://Sprites/lightningball.png")
	if !get_parent().charms[1][1] and !get_parent().charms[2][1] and !get_parent().charms[0][1]:
		bounces = 0
		autoangle = false
		texture.texture = load("res://Sprites/basicorb.png")


func setvariables():
	charging = get_parent().charging
	angle = Vector2.ZERO #nem mozog a projectile charge közben
	if projectiletween != null:
		projectiletween.kill() #lereseteli a projectiletweent azzal, hogy mindig megöli
	if charging: #elengedésnél megadja a projectilenak a változókat
		exploded = false
		nearenemy.clear()
		position = Vector2(0,-60)
		inattackzone.clear()
		projectiletween = get_tree().create_tween()
		projectiletween.set_parallel(true)
		attackchargeprogress.visible = true
		attackchargeprogress.value = 0
		visible = true
		charmcheck()
		projectiletween.tween_property(attackchargeprogress, "value", 100, attackchargetime)
		projectiletween.tween_property(self, "scale", Vector2(3,3), attackchargetime)
		projectiletween.tween_property(self, "speed", minspeed, attackchargetime)
		projectiletween.tween_property(self, "damage", maxdamage, attackchargetime)
		attackprogress.value = 0
	else:
		attackchargeprogress.visible = false
		get_parent().attacking = false
		get_parent().attacked = true
		attackcooldown.start()
		var attackcdtween = get_tree().create_tween()
		attackcdtween.tween_property(attackprogress, "value", 100, attackcooldown.time_left)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if get_parent().charms[0][1]:
		autoangle = true
		enemyfinder.position.y = 30000
		enemyfinder.position.y = 0
		inattackzone.append(area.get_parent())
		enemyfinder.monitoring = true
	if get_parent().charms[2][1]: #robbanásnál damage, onhit damaget nem használja
		if !exploded:
			inattackzone.clear()
			for enemies in inexplosionarea:
				if enemies.cantakedamage:
					enemies.health -= damage
					enemies.get_node("effects").play("blink")
			get_parent().get_node("ExplosionAnimation").play("default")
			get_parent().get_node("ExplosionAnimation").global_position = global_position
			get_parent().get_node("ExplosionAnimation").scale = Vector2(3.88, 3.88) + scale
			$ExplosionArea/AudioStreamPlayer2D.play()
		exploded = true
	elif get_parent().charms[1][1]: #enemyt hozzáad az attackzonehoz
		inattackzone.append(area.get_parent())
		lightningcooldown.start()
	else:
		inattackzone.append(area.get_parent())
		for enemies in inattackzone: #ricochet és sima attack damage
			inattackzone.erase(enemies)
			nearenemy.erase(enemies)
			if enemies.cantakedamage and active:
				$ProjectileHit.play()
				enemies.health -= damage
	if bounces == 0: #ha már nem tud többet pattanni a projectile akkor kiszedi
		active = false
		visible = false
		position = Vector2(0,-60)
	else:
		bounces -= 1
		if autoangle == true and len(nearenemy) > 0 and is_instance_valid(nearenemy[0]): #hitnél beállítja a következő célpontot ha van megfelelő charm
			angle = global_position.direction_to(nearenemy[0].global_position)
			

func _physics_process(delta: float) -> void:
	if get_parent().attacked and get_parent().get_meta("active") and !autoangle:
		active = true
		angle = global_position.direction_to(get_global_mouse_position()) #ha karakter irányítva van akkor a kurzor helyzete az irány
	if get_parent().attacked and autoangle and len(nearenemy) > 0 and is_instance_valid(nearenemy[0]): #beállítja a következő enemyt angleként
		active = true
		angle = global_position.direction_to(nearenemy[0].global_position)
	if global_position.distance_squared_to(get_global_mouse_position()) > 50 and visible: #fixeli a buggolást a movementnél
		move_and_collide(angle * speed * delta) 
	if !get_parent().attacked:
		inattackzone.clear()
		lightningcooldown.stop()
	if inwall: #kiveszi a falból a projectilet ha benne van
		position.y += 5
	

func _on_wall_check_body_entered(body: Node2D) -> void: #megnézi, hogy falban van e a projectile
	if body != self:
		inwall = true


func _on_wall_check_body_exited(_body: Node2D) -> void: #megnézi, hogy falban van e a projectile
	inwall = false


func _on_explosion_area_area_entered(area: Area2D) -> void:
	inexplosionarea.append(area.get_parent())


func _on_enemy_finder_area_entered(area: Area2D) -> void:
	if area.get_parent() not in nearenemy:
		nearenemy.append(area.get_parent())


func _on_explosion_area_area_exited(area: Area2D) -> void:
	inexplosionarea.erase(area.get_parent())


func _on_ball_lightning_cooldown_timeout() -> void:
	for enemies in inattackzone:
		var arc = $Area2D/hittexturecopy.duplicate()
		$Area2D.add_child(arc)
		arc.visible = true
		arc.texture = load("res://Sprites/lightning_smol%d.png" % (randi_range(0,3)))
		arc.name = "balltexture"
		arc.rotation = (global_position.angle_to_point(enemies.global_position)+89.65)
		if enemies.cantakedamage == true:
			enemies.health -= damage
			$ProjectileHit.play()
	await get_tree().create_timer(0.2).timeout
	for elements in $Area2D.get_children():
		if elements.name.contains("balltexture"):
			elements.queue_free()


func _on_area_2d_area_exited(area: Area2D) -> void:
	inattackzone.erase(area.get_parent())
