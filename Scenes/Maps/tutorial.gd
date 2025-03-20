extends Node2D

func _ready() -> void:
	var config = ConfigFile.new()
	config.load("user://config.cfg")
	config.set_value("playerdata", "hasplayedtutorial", "true")
	config.save("user://config.cfg")
