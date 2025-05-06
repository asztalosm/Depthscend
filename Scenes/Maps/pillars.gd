extends Node2D
@onready var pillars = get_children()
var secondcounter = 0
func _ready() -> void:
	pillars.erase($RespawnTimer) #surely this hack won't be a problem later
	pillars.erase($TimeCheckTimer)


func _on_respawn_timer_timeout() -> void:
	var notdeadcounter = 0
	for pillar in pillars:
		if !pillar.isdestroyed:
			notdeadcounter += 1
		pillar.isdestroyed = false
	if notdeadcounter > 0:
		for pillar in pillars:
			pillar.truehealth = 4
			pillar.get_node("Orb").visible = true
			pillar.get_node("Orb/AnimatedSprite2D").frame = 4
		$TimeCheckTimer.start()
		secondcounter = 0
		for flowers in get_parent().get_node("Flowers").get_children():
			flowers.animation = "default"
	else:
		get_parent().get_parent().get_node("Portal/PortalBg").visible = true
		get_parent().get_parent().get_node("Portal/GPUParticles2D").visible = true


func _on_time_check_timer_timeout() -> void:
	secondcounter += 1
	if secondcounter > 0 and secondcounter <= 22:
		get_parent().get_node("Flowers").get_node("Flower%d" % secondcounter).animation = "active"
