extends Node2D
@onready var characters = [get_node("character1"), get_node("character2"), get_node("character3")]
@onready var playercam = get_node("Camera2D")
@onready var playerhealth = $GUI/CurrentCharacter/HealthLabel
@onready var health = $GUI/CurrentCharacter/Health
@onready var currentcharacter = $GUI/CurrentCharacter
@onready var DeathScreen = $GUI/DeathScreen
var globalcurrentchar = 0
var pausedgame = false

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
	if characters[0].get_meta("isDead") and characters[1].get_meta("isDead") and characters[2].get_meta("isDead"):
			currentcharacter.visible = false
			DeathScreen.visible = true
			var tween = DeathScreen.create_tween()
			tween.tween_property(DeathScreen, "modulate:a", 1, 0.35)
	else:
		playercam.position = characters[globalcurrentchar].position
		playerhealth.text = str(characters[globalcurrentchar].health) + "/" + str(characters[globalcurrentchar].maxhealth)
		var tween = get_tree().create_tween()
		health.max_value = characters[globalcurrentchar].maxhealth
		tween.tween_property(health, "value", float(characters[globalcurrentchar].health), 0.2) # átméretezi a healthbart a játékos jelenlegi karakterének életerejével megfelelőnek
