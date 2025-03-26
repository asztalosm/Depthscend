extends CharacterBody2D
@export var health = 12
@export var maxhealth = 12
@export var damage = 2
@export var speed = 280
@export var cantakedamage = true
var target = self
var dir = Vector2.ZERO
var dontrefresh = false
var canattack = true
@onready var hudhealthlabel = $Health/Label


func _process(_delta: float) -> void:
	if health > 0:
		if target != self and !dontrefresh and target != null:
			var wormrotation = get_angle_to(target.global_position) + deg_to_rad(55)
			rotate(wormrotation)
			dir = target.global_position - global_position
			velocity = Vector2(0,0)
			if dir.length_squared() > 1.0:
				dir = dir.normalized()
				velocity = dir * speed
		move_and_slide()
	else:
		await get_tree().create_timer(0.2).timeout
		queue_free()
	if target != self or health != maxhealth:
		hudhealthlabel.get_parent().visible = true
		$Health.global_position = global_position + Vector2(-29, -16)
		
	hudhealthlabel.text = str(health) + "/" + str(maxhealth)

func _on_detection_area_entered(area: Area2D) -> void:
	if target == self and area != null:
		target = area.get_parent()
		$AnimatedSprite2D.play("walk")


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if canattack:
		dontrefresh = true
		canattack = false
		if area.get_parent().cantakedamage:
			area.get_parent().health -= damage
			area.get_parent().get_node("effects").play("blink")
		$Timer.start()


func _on_timer_timeout() -> void:
	dontrefresh = false
	canattack = true
