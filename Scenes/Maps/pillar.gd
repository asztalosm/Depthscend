extends Sprite2D
@export var health = 0
var truehealth = 5
var oldhealth = health
var isdestroyed = false
@export var cantakedamage = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if oldhealth != health:
		oldhealth = health
		truehealth -= 1
		$Orb/AnimatedSprite2D.frame = truehealth-1
		if truehealth <= 0:
			isdestroyed = true
			$Orb.visible = false
