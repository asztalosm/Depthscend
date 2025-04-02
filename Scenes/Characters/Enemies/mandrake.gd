extends CharacterBody2D
@export var health = 7
@export var maxhealth = 7
@export var damage = 1
@export var speed = 245
@export var cantakedamage = true
var isactive = false
var dir := Vector2.ZERO
var indetectionzone = []
var target = self
var notTargeting = true
var attackedenemy = null
var inattackzone = []

@onready var navagent = $NavigationAgent2D
@onready var animatedsprite = $AnimatedSprite2D
@onready var detection = $Detection
@onready var hudhealthlabel = $Health/Label

func active() -> void:
	animatedsprite.play("spawn")
	await get_tree().create_timer(0.5).timeout
	isactive = true


func gettargetpos(navtarget):
	navagent.target_position = navtarget.global_position

func _on_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		indetectionzone.append(area.get_parent())
		if !isactive:
			active()


func _process(_delta: float) -> void:
	if indetectionzone != []:
		target = indetectionzone[0]
		notTargeting = false
	else:
		target = self
	if self.health > 0:
		if target.health > 0:
			_on_timer_timeout()
		else:
			detection.scale.x = 0.01
			detection.scale.y = 0.01
			detection.global_position = Vector2(30000, 0)
			notTargeting = true #targetelést reseteli ha idő közben meghal az eredetileg támadott target
			detection.scale.x = 1
			detection.scale.y = 1
			detection.position = Vector2.ZERO
		if isactive:
			dir = navagent.get_next_path_position() - global_position
			velocity = Vector2(0,0)
			if dir.length_squared() > 1.0:
				dir = dir.normalized()
				velocity = dir * speed
			#	var angletocursor = rad_to_deg(self.get_angle_to(navagent.get_next_path_position())) - 90
			#	if angletocursor < 0:
			#		angletocursor += 360 
			#	currentsprite = round(angletocursor / 45) #all characters have a walk8 animation that matches up with the walk0 animation so the debugger stops bitching
			if velocity > Vector2(0,0): #could only manage this buggy code :sob:
				animatedsprite.play("walk")
				animatedsprite.flip_h = true
			elif velocity < Vector2(0,0):
				animatedsprite.flip_h = false
				animatedsprite.play("walk")
			elif animatedsprite.animation != "spawn":
				animatedsprite.stop()
			move_and_slide()
	else:
		await get_tree().create_timer(0.2).timeout
		queue_free()
	if !notTargeting or health != maxhealth:
		hudhealthlabel.get_parent().visible = true
		
	hudhealthlabel.text = str(health) + "/" + str(maxhealth)
		
	


func _on_timer_timeout() -> void:
	gettargetpos(target)
	
	
func _on_attackhitbox_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters" and attackedenemy == null:
		attackedenemy = area.get_parent()
		inattackzone.append(area.get_parent())
	else:
		pass




func _on_attack_cooldown_timeout() -> void:
	if attackedenemy != null:
		attackedenemy.health -= damage
		var charactereffect = preload("res://Shaders/characterstatuseffects.tscn").instantiate()
		attackedenemy.add_child(charactereffect)
		charactereffect.texture = preload("res://Particles/MandrakeAttack.png")
		charactereffect.global_position = attackedenemy.global_position + Vector2(0, -24)
		charactereffect.emitting = true


func _on_attackhitbox_area_exited(area: Area2D) -> void:
	inattackzone.erase(area.get_parent())
	if inattackzone == []:
		attackedenemy = null
	else:
		target = inattackzone[0]
