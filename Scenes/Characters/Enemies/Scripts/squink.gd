extends CharacterBody2D
@onready var navagent = $NavigationAgent2D
@export var speed = 75
@export var accel = 35
@export var health = 5
var dir := Vector2.ZERO
var notTargeting = true
var _target = self
@onready var detection = $Detection
@onready var ExplosionTimer = $ExplosionTimer
var InExplosionRadius = []

func _on_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "character1" and notTargeting or area.get_parent().name == "character2" and notTargeting or area.get_parent().name == "character3" and notTargeting: # csak abban az esetben kezd el követni JÁTÉKOST ha már nem követ egyet.
		notTargeting = false
		detection.scale.x = 0.01
		detection.scale.y = 0.01
		_target = area.get_parent()
		gettargetpos(_target)
	else:
		pass

func gettargetpos(target):
	navagent.target_position = target.position


func _process(_delta: float) -> void:
	if _target.health > 0:
		_on_timer_timeout()
	else:
		notTargeting = true #targetelést reseteli ha idő közben meghal az eredetileg támadott target
		detection.scale.x = 1
		detection.scale.y = 1
	if health > 0:
		dir = navagent.get_next_path_position() - global_position
		if dir.length_squared() > 1.0:
			dir = dir.normalized()
		velocity = velocity.lerp(dir * speed, accel * _delta)
		move_and_slide()
	else:
		visible = false


func _on_timer_timeout() -> void:
	gettargetpos(_target)

func _on_explosion():
	for i in InExplosionRadius:
		i.health -= 5
	queue_free()

func _on_explosion_size_area_entered(area: Area2D) -> void:
	InExplosionRadius.append(area.get_parent())
	print(InExplosionRadius)
	if area.get_parent().name == "character1" or area.get_parent().name == "character2" or area.get_parent().name == "character3":
		var tween = create_tween()
		#színkezelés robbanáskor, változni fog mert ez jelenleg szarul néz ki, lényeg, hogy create timerben az idő megegyezzen velük + kis deadzone
		tween.tween_property(self, "modulate:r", 5, 0.75)
		tween.tween_property(self, "modulate:r", 0, 0.5)
		tween.tween_property(self, "modulate:r", 10, 0.5)
		tween.tween_property(self, "modulate:r", 0, 0.35)
		tween.tween_property(self, "modulate:r", 40, 0.8)
		
		#timer a robbanásig
		await get_tree().create_timer((0.75+0.5+0.5+0.35+1.2)).timeout
		area.get_parent().health -= 5
		queue_free()
		_on_explosion()


func _on_detection_area_exited(area: Area2D) -> void:
	InExplosionRadius.erase(area)
