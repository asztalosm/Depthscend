extends CharacterBody2D
@export var target = null
@onready var navagent = $NavigationAgent2D as NavigationAgent2D
@export var health = 1
@export var speed = 320
@export var cantakedamage = true


func _process(_delta: float) -> void:
	if target != null:
		navagent.target_position = target.position + Vector2(0,-24)
		if health > 0:
			var dir = navagent.get_next_path_position() - global_position
			velocity = Vector2(0,0)
			if dir.length_squared() > 1.0:
				dir = dir.normalized()
				velocity = dir * speed
				rotation = get_angle_to(dir)
			move_and_slide()
		else:
			await get_tree().create_timer(0.2).timeout
			queue_free()


func _on_hit_check_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		area.get_parent().health -= 1
		var charactereffect = preload("res://Shaders/characterstatuseffects.tscn").instantiate()
		area.get_parent().get_parent().add_child(charactereffect)
		charactereffect.texture = preload("res://Particles/bobtrail.png")
		charactereffect.global_position = area.get_parent().global_position
		charactereffect.amount = 2
		charactereffect.emitting = true
		area.get_parent().get_node("effects").play("blink")
		queue_free()
