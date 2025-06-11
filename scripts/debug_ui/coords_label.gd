extends Label

@onready var player: CharacterBody3D = get_node("/root/World/Player")

func _ready() -> void:
	update_text()

func _process(_delta: float) -> void:
	update_text()

func update_text() -> void:
	text = str("Coords: ", player.position)
