extends Area2D
var characterinzone = false
var charactersnode
var charmlist = [
	[load("res://Textures/Groundslam.png"), "character1", "hasgroundslamcharm"],
	[load("res://Textures/ExplosionOrb.png"), "character3", "hasexplosionorb"],
	[load("res://Textures/Balllightning.png"), "character3", "hasballlightning"],
	[load("res://Textures/Ricochet.png"), "character3", "hasricochet"],
	[load("res://Textures/Dash.png"), "character2", "hasdashcharm"],
	[load("res://Textures/Soultear.png"), "character2", "hassoultearcharm"],
]
var open = false
var currentcharacter = null
var charactersinzone = []

@onready var charm = $Charm
@onready var charmtexture = $Charm/CharmTexture
@onready var chesttexture = $ChestTexture

@export var selectedcharmtexture = null
@export var selectedcharm = null
@export var charmcharacter = null

func rollcharm() -> void:
	var charmnum = randi_range(0, len(charmlist)-1)
	charm.usable = true
	selectedcharmtexture = charmlist[charmnum][0]
	charmcharacter = charmlist[charmnum][1]
	selectedcharm = charmlist[charmnum][2]
	charm.currentcharm = selectedcharm
	charm.usablecharacter = charactersnode.get_node(charmcharacter)
	$Charm/CollisionShape2D.disabled = false
	charmtexture.visible = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("kb_E") and characterinzone and !open and currentcharacter.get_meta("active"):
		rollcharm()
		open = true
		if chesttexture.texture == load("res://Textures/chest_front.png"):
			chesttexture.texture = load("res://Textures/chest_front_open.png")
		else:
			chesttexture.texture = load("res://Textures/chest_side_open.png")
		$UseButton.visible = false
		charm.visible = true
		charmtexture.texture = selectedcharmtexture
		$Charm/CharacterBG.visible = true
		$Charm/CharacterBG/CharacterTexture.texture = load("res://Sprites/"+charmcharacter+".png")


func _process(_delta: float) -> void:
	if characterinzone:
		if currentcharacter.get_meta("active") and !open:
			$UseButton.visible = true
		else:
			$UseButton.visible = false

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters" and !area.get_parent().get_meta("isDead") and !open:
		self.modulate = Color(1,1,1)
		characterinzone = true
		currentcharacter = area.get_parent()
		charactersnode = area.get_parent().get_parent()



func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent().name == "Characters" and !area.get_parent().get_meta("isDead") and area.get_parent().get_meta("active") and !open:
		characterinzone = false
		$UseButton.visible = false
		self.modulate = Color(0.8,0.8,0.8)
