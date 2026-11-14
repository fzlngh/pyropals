extends Node2D
@export var background_texture: Texture2D  

@export var bg_scale: Vector2 = Vector2(3.0, 3.0)

@export var copies: int = 3

var bg_sprites: Array[Sprite2D] = []
var player: Node2D = null
var tile_width: float = 0.0  


func _ready() -> void:
	position = Vector2(0, -200)
	if not background_texture:
		push_warning("BackgroundManager: 'Background Texture' belum diisi di Inspector!")
		return

	tile_width = background_texture.get_width() * bg_scale.x

	for i in range(copies):
		var spr := Sprite2D.new()
		spr.texture = background_texture
		spr.centered = false      
		spr.scale = bg_scale        
		spr.position = Vector2(i * tile_width, 0)
		add_child(spr)
		bg_sprites.append(spr)

	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("BackgroundManager: tidak ketemu node di group 'player'. BG tidak akan ikut loop.")


func _process(_delta: float) -> void:
	if not player or bg_sprites.is_empty():
		return

	for spr in bg_sprites:
		if player.global_position.x - spr.position.x > tile_width * 1.5:
			spr.position.x += tile_width * copies
