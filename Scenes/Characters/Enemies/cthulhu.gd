extends CharacterBody2D
@onready var navagent = $NavigationAgent2D
@export var speed = 260
@export var accel = 35
@export var health = 8
@export var maxhealth = 8
@export var damage = 3
var dir := Vector2.ZERO
var notTargeting = true
var _target = self
@onready var detection = $Detection
@onready var hudhealthlabel = $Health/Label
@export var cantakedamage = true
var currentsprite = 0
@onready var animatedsprite = $AnimatedSprite2D
var attackedenemy = null

func gettargetpos(target):
	navagent.target_position = target.global_position

func _on_detection_area_entered(area: Area2D) -> void: #másolt detection script squinkről
	if area.get_parent().name == "character1" and notTargeting or area.get_parent().name == "character2" and notTargeting or area.get_parent().name == "character3" and notTargeting: # csak abban az esetben kezd el követni JÁTÉKOST ha már nem követ egyet.
		notTargeting = false
		detection.scale.x = 0.01
		detection.scale.y = 0.01
		_target = area.get_parent()
		gettargetpos(_target)
	else:
		pass



func _process(_delta: float) -> void:
	if self.health > 0:
		if _target.health > 0:
			_on_timer_timeout()
		else:
			detection.scale.x = 0.01
			detection.scale.y = 0.01
			detection.global_position = Vector2(30000, 0)
			notTargeting = true #targetelést reseteli ha idő közben meghal az eredetileg támadott target
			detection.scale.x = 1
			detection.scale.y = 1
			detection.position = Vector2.ZERO
		if health > 0:
			dir = navagent.get_next_path_position() - global_position
			velocity = Vector2(0,0)
			if dir.length_squared() > 1.0:
				dir = dir.normalized()
				velocity = dir * speed
				var angletocursor = rad_to_deg(self.get_angle_to(navagent.get_next_path_position())) - 90
				if angletocursor < 0:
					angletocursor += 360 
				currentsprite = round(angletocursor / 45) #all characters have a walk8 animation that matches up with the walk0 animation so the debugger stops bitching
			if velocity != Vector2(0,0): #could only manage this buggy code :sob:
				animatedsprite.play(str("walk",int(currentsprite)))
			else:
				animatedsprite.stop()
			move_and_slide()
		else:
			visible = false
	else:
		await get_tree().create_timer(0.2).timeout
		queue_free()
	if !notTargeting or health != maxhealth:
		hudhealthlabel.get_parent().visible = true
		
	hudhealthlabel.text = str(health) + "/" + str(maxhealth)

func _on_timer_timeout() -> void:
	gettargetpos(_target)


func _on_attackhitbox_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters" and $AttackCooldown.time_left == 0:
		attackedenemy = area.get_parent()
		if attackedenemy != null:
			attackedenemy.health -= 3
			$AttackAnim.play("default")
			$AttackCooldown.start()
	else:
		pass


func _on_attack_cooldown_timeout() -> void:
	if attackedenemy != null:
		attackedenemy.health -= 3
		$AttackAnim.play("default")
		$AttackCooldown.start()


func _on_attackhitbox_area_exited(_area: Area2D) -> void:
	attackedenemy = null
