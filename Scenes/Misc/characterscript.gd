extends Node2D
@onready var characters = [get_node("character1"), get_node("character2"), get_node("character3")]
@export var exportchars = []
@onready var playercam = get_node("Camera2D")
@onready var playerhealth = $GUI/CurrentCharacter/HealthLabel
@onready var health = $GUI/CurrentCharacter/Health
@onready var currentcharacter = $GUI/CurrentCharacter
@onready var DeathScreen = $GUI/DeathScreen
@onready var charactericon = $GUI/CurrentCharacter/Icon/Icon as TextureRect
@onready var currentcharacterlabel = $GUI/CurrentCharacter/Icon/CharacterNumber/Label as Label
@onready var secondcharacterhealth = $GUI/InactiveCharacters/OtherCharacter1/Health/Health
@onready var secondcharacterhealthtext = $GUI/InactiveCharacters/OtherCharacter1/Health/HealthLabel
@onready var secondcharactericon = $GUI/InactiveCharacters/OtherCharacter1/Icon/Icon
@onready var secondcharactericonnumber = $GUI/InactiveCharacters/OtherCharacter1/Icon/CharacterNumber/Label
@onready var thirdcharacterhealth = $GUI/InactiveCharacters/OtherCharacter2/Health/Health
@onready var thirdcharacterhealthtext = $GUI/InactiveCharacters/OtherCharacter2/Health/HealthLabel
@onready var thirdcharactericon = $GUI/InactiveCharacters/OtherCharacter2/Icon/Icon
@onready var thirdcharactericonnumber = $GUI/InactiveCharacters/OtherCharacter2/Icon/CharacterNumber/Label
@export var globalcurrentchar = 0
var secondtaken = false #második playerslot

func _ready() -> void:
	exportchars = characters #ugly hack

# karakterválasztásért felelős funkció, loopol a charlisten megnézi melyik gombot nyomtuk meg, irányítást átadja, kamerának megadja melyiket kell követnie
func _input(event: InputEvent) -> void:
	for i in range(characters.size()):
		if event.is_action_pressed("Number %d Character Selection" % (i + 1)):
			if characters[i].health <= 0:
				print("character already dead")
			else:
				secondtaken = false
				globalcurrentchar = i
				currentcharacterlabel.text = str(globalcurrentchar+1)
				charactericon.texture = load("res://Sprites/character%d.png" % (int(globalcurrentchar+1)))
				for currentchar in range(characters.size()):
					characters[currentchar].set_meta("active", currentchar == i)
					


# folyamatosan futó funkció ami a jelenleg kiválasztott karaktert követi, életet is kiírja hudra
func _process(_delta: float) -> void:
	if characters[0].get_meta("isDead") and characters[1].get_meta("isDead") and characters[2].get_meta("isDead"):
			currentcharacter.visible = false
			$GUI/InactiveCharacters.visible = false
			DeathScreen.visible = true
			var tween = DeathScreen.create_tween()
			tween.tween_property(DeathScreen, "modulate:a", 1, 0.35)
	else:
		for chars in characters:
			if chars == characters[globalcurrentchar]:
				playercam.position = chars.position
				if chars.health <= 0:
					playerhealth.text = "💀"
				else:
					playerhealth.text = str(chars.health) + "/" + str(chars.maxhealth)
				var tween = get_tree().create_tween()
				health.max_value = characters[globalcurrentchar].maxhealth
				tween.tween_property(health, "value", float(characters[globalcurrentchar].health), 0.2) # átméretezi a healthbart a játékos jelenlegi karakterének életerejével megfelelőnek
			else:
				if !secondtaken: #listában első karakter ami nem aktív elhelyezése a hudon a második hud ikonra
					secondtaken = true
					secondcharacterhealth.max_value = chars.maxhealth
					if chars.health <= 0:
						secondcharacterhealthtext.text = "💀"
					else:
						secondcharacterhealthtext.text = str(chars.health) + "/" + str(chars.maxhealth)
					secondcharactericonnumber.text = chars.name.reverse().left(1)
					secondcharactericon.texture = load("res://Sprites/character%d.png" % (int(chars.name.reverse().left(1)))) #xddd ez annyira jank és undorító de benne hagyom
					var tween = get_tree().create_tween()
					tween.tween_property(secondcharacterhealth, "value", float(chars.health), 0.2)
				else: #harmadik karakter elhelyezése
					thirdcharacterhealth.max_value = chars.maxhealth
					if chars.health <= 0:
						thirdcharacterhealthtext.text = "💀"
					else:
						thirdcharacterhealthtext.text = str(chars.health) + "/" + str(chars.maxhealth)
					thirdcharactericonnumber.text = chars.name.reverse().left(1)
					thirdcharactericon.texture = load("res://Sprites/character%d.png" % (int(chars.name.reverse().left(1)))) #xddd ez annyira jank és undorító de benne hagyom
					secondtaken = false #crazy hack hogy updateolja az életet
					var tween = get_tree().create_tween()
					tween.tween_property(thirdcharacterhealth, "value", float(chars.health), 0.2)
