extends Node2D
@onready var characters = [get_node("character1"), get_node("character2"), get_node("character3")]
@onready var playercam = get_node("Camera2D")
@onready var playerhealth = $GUI/CurrentCharacter/HealthLabel
@onready var health = $GUI/CurrentCharacter/Health
var globalcurrentchar = 0
# karakterválasztásért felelős funkció, loopol a charlisten megnézi melyik gombot nyomtuk meg, irányítást átadja, kamerának megadja melyiket kell követnie
func _input(event: InputEvent) -> void:
	for i in range(characters.size()):
		if event.is_action_pressed("Number %d Character Selection" % (i + 1)):
			if characters[i].health <= 0:
				print("character already dead")
			else:
				globalcurrentchar = i
				for currentchar in range(characters.size()):
					characters[currentchar].set_meta("active", currentchar == i)

# folyamatosan futó funkció ami a jelenleg kiválasztott karaktert követi, életet is kiírja hudra
func _process(_delta: float) -> void:
	playercam.position = characters[globalcurrentchar].position
	playerhealth.text = str(characters[globalcurrentchar].health) + "/" + str(characters[globalcurrentchar].maxhealth)
	health.size.x = float(characters[globalcurrentchar].health / float(characters[globalcurrentchar].maxhealth)) * $GUI/CurrentCharacter/HealthBG.size.x # átméretezi a healthbart a játékos jelenlegi karakterének életerejével megfelelőnek
