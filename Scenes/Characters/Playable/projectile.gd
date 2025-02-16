extends Area2D
@export var speed = 500
var cooledattack = true # attack cooldown bool
@onready var attackcooldown = self.get_parent().get_node("AttackCooldown")
var target = position
var velocity = null
var angle = 0.0

func _ready() -> void:
	self.top_level = true
	visible = false

func _process(delta: float) -> void:
	if visible:
		velocity = Vector2(cos(angle), sin(angle)) * speed
		position += velocity * delta * 2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("rclick") and self.get_parent().get_meta("active") and !self.get_parent().get_meta("isDead") and cooledattack:
		self.position = get_parent().position
		self.monitoring = true
		cooledattack = false
		visible = true
		attackcooldown.start()
		target = get_global_mouse_position()
		angle = position.angle_to_point(target)
		self.get_parent().get_node("AttackProgress").value = 0
		var attackprogresstween = get_tree().create_tween()
		attackprogresstween.tween_property(self.get_parent().get_node("AttackProgress"), "value", 100, attackcooldown.time_left)

func _on_attack_cooldown_timeout() -> void: # "despawns" projectile
	cooledattack = true
	visible = false
	position = Vector2(0, 0)
	target = position


func _on_area_entered(area: Area2D) -> void: #damages enemy
	visible = false
	if area.get_parent().get_parent().name == "Characters":
		pass
	elif area.get_parent().get_parent().name == "Enemies":
		area.get_parent().health -= get_parent().damage
	else:
		pass
		


func _on_body_entered(_body: Node2D) -> void: # wall collision detection
	visible = false
	position = Vector2(0, 0)
	target = position
	
