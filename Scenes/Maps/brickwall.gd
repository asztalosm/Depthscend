extends TextureRect
var health = 25
var cantakedamage = true



func _on_timer_timeout() -> void:
	if health >= 25:
		texture = load("res://Tilemaps/breakablebrickfence0.png")
	elif health < 25 and health >= 11:
		texture = load("res://Tilemaps/breakablebrickfence1.png")
	elif health <= 10 and health > 0:
		texture = load("res://Tilemaps/breakablebrickfence2.png")
	else:
		texture = load("res://Tilemaps/breakablebrickfence3.png")
		$Timer.queue_free()
		$AudioStreamPlayer2D.play()
		$GPUParticles2D.emitting = true
		$StaticBody2D.queue_free()
