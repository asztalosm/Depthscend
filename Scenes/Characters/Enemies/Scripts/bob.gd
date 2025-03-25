extends CharacterBody2D
@export var health = 3
@export var maxhealth = 3
@export var damage = 3
@export var cantakedamage = true

@onready var detection = $Detection
@onready var hudhealthlabel = $Health/Label
@onready var animatedsprite = $AnimatedSprite2D
@onready var raycast = $RayCast2D
@onready var attackcooldown = $AttackCooldown
var currentsprite = 0
var notTargeting = true
var attackedenemy = null
var detectionlist = []
var canhitlist = []

func attack():
	if attackcooldown.time_left == 0:
		if canhitlist != []:
			$AnimatedSprite2D.play("default")
		for characters in canhitlist:
			var projectilescene = load("res://Scenes/Characters/Enemies/bobprojectile.tscn") as PackedScene
			var projectile = projectilescene.instantiate()
			projectile.target = characters
			projectile.position = Vector2(randi_range(-24,24), randi_range(-24,24))
			add_child(projectile)
		attackcooldown.start()
	canhitlist.clear()
			

func _process(_delta: float) -> void:
	if health > 0:
		pass
	else:
		await get_tree().create_timer(0.2).timeout
		queue_free()
	if !notTargeting or health != maxhealth:
		hudhealthlabel.get_parent().visible = true
	hudhealthlabel.text = str(health) + "/" + str(maxhealth)


func _on_ray_cast_check_timeout() -> void:
	for character in detectionlist:
		raycast.target_position = character.global_position - position #sets raycast target relative to itself because target_position is not global_position :sob:
		if raycast.is_colliding():
			canhitlist.erase(character)
		else:
			canhitlist.append(character)
	attack()

func _on_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters":
		detectionlist.append(area.get_parent())
		notTargeting = false


func _on_detection_area_exited(area: Area2D) -> void:
	if area.get_parent() in detectionlist:
		detectionlist.erase(area.get_parent())
