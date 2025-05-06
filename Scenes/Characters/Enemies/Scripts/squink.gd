extends CharacterBody2D
@onready var navagent = $NavigationAgent2D
@export var speed = 150
@export var accel = 35
@export var health = 5
@export var maxhealth = 5
@export var damage = 4
var dir := Vector2.ZERO
var notTargeting = true
var _target = self
@onready var detection = $Detection
var InExplosionRadius = []
@onready var hudhealthlabel = $Health/Label
@export var cantakedamage = true

func gettargetpos(target):
	navagent.target_position = target.global_position
func _on_detection_area_entered(area: Area2D) -> void:
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
			if dir.length_squared() > 1.0:
				dir = dir.normalized()
			velocity = dir * speed
			move_and_slide()
		else:
			visible = false
	else:
		_on_explosion()
	if !notTargeting or health != maxhealth:
		hudhealthlabel.get_parent().visible = true
		
	hudhealthlabel.text = str(health) + "/" + str(maxhealth)

func _on_timer_timeout() -> void:
	gettargetpos(_target)

func _on_explosion():
	for i in InExplosionRadius:
		if i.cantakedamage:
			i.health -= damage
			i.get_node("effects").play("blink")
		else:pass
	queue_free()

func _on_explosion_size_area_entered(area: Area2D) -> void:
	if area.get_parent() in InExplosionRadius:
		InExplosionRadius.erase(area.get_parent())
	else:
		InExplosionRadius.append(area.get_parent())
	if area.get_parent().name == "character1" or area.get_parent().name == "character2" or area.get_parent().name == "character3":
		$explosioneffect.play("explosion")



func _on_explosion_size_area_exited(area: Area2D) -> void:
	InExplosionRadius.erase(area.get_parent())
