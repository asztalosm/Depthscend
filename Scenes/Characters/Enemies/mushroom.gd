extends CharacterBody2D
@export var health = 1
@export var maxhealth = 1
@export var cantakedamage = true
var inhealrange = []
func _ready() -> void:
	$AnimatedSprite2D.frame = randi_range(0,3)

func heal() -> void:
	for characters in inhealrange:
		if characters.get_parent().name == "Characters":
			characters.health -= 2
			characters.get_node("effects").play("blink")
		else:
			if characters.health <= characters.maxhealth -2:
				characters.health += 2
			else:
				characters.health = characters.maxhealth
			var charactereffect = preload("res://Shaders/characterstatuseffects.tscn").instantiate()
			characters.add_child(charactereffect)
			charactereffect.texture = preload("res://Particles/Heal.png")
			charactereffect.global_position = characters.global_position
			charactereffect.emitting = true
			characters.get_node("effects").play("heal")
	queue_free()

func _process(_delta: float) -> void:
	if health <= 0:
		heal()


func _on_heal_range_area_entered(area: Area2D) -> void:
	inhealrange.append(area.get_parent())


func _on_heal_range_area_exited(area: Area2D) -> void:
	inhealrange.erase(area.get_parent())
