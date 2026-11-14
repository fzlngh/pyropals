extends Node2D
@export var backgrounds: Array[Texture2D] = []
@export var random_order: bool = true

@onready var bg_sprite: Sprite2D = $BGsprite

func _ready() -> void:
	set_background_for_session()

var current_index: int = -1

func set_background_for_session(index: int = -1) -> void:
	if backgrounds.is_empty():
		push_warning("BackgroundManager: array 'backgrounds' masih kosong!")
		return

	if index >= 0:
		current_index = index % backgrounds.size()
	elif random_order: 
		current_index = randi() % backgrounds.size()
	else:
		current_index = (current_index + 1) % backgrounds.size()

	bg_sprite.texture = backgrounds[current_index]
