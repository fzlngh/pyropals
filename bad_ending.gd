extends Node2D
@export var background_texture: Texture2D

@export var player_scene: PackedScene
@export var player_start_position: Vector2 = Vector2(-60, 560)
@export var player_walk_target_x: float = 700.0

@onready var bg_sprite: Sprite2D = $BGSprite
@onready var restart_button: TextureButton = get_node_or_null("RestartButton")


func _ready() -> void:
	position = Vector2(590, 300)
	scale = Vector2(0.78, 0.8)
	get_tree().paused = false  

	if background_texture:
		bg_sprite.texture = background_texture

	if player_scene:
		var p := player_scene.instantiate()
		add_child(p)
		
		p.global_position = player_start_position
		if p.has_method("start_auto_walk"):
			p.start_auto_walk(player_walk_target_x)

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scene.tscn")
