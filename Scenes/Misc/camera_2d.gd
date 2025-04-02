extends Camera2D

@onready var bg = get_node("Background")

# i guess ettől mozog menőn a háttér egy általam nem ismert ok miatt, a háttér konziztens lenne ha a játékost követné de menőbb ha elcsúszik, this stays 😎 (????)
func _process(_delta: float) -> void:
	bg.position.x = self.position.x / 5 - 2000 # minél kisebb az osztó annál jobban mozog a háttér 
	bg.position.y = self.position.y / 5 - 4000 # kivonást azért használunk hogy beleférjen a kép anélkül, hogy nagyon nagyon óriási képeket használjunk
