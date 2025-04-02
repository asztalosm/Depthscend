extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await self.finished
	queue_free()
