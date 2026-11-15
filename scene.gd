extends Node2D

@export var lebar_tanah: float = 1152.0

@onready var player: CharacterBody2D = $Player
@onready var tanah_awal: Node2D = $tanah

var ujung_kanan_tanah: float = 0.0


func _ready() -> void:
	ujung_kanan_tanah = tanah_awal.position.x + lebar_tanah
	GameManager.reset_session()
	$ObstacleSpawner.set_player(player)

func _process(_delta: float) -> void:
	if player.global_position.x + lebar_tanah > ujung_kanan_tanah:
		var tanah_baru := tanah_awal.duplicate()
		tanah_baru.position = Vector2(ujung_kanan_tanah, tanah_awal.position.y)
		add_child(tanah_baru)
		ujung_kanan_tanah += lebar_tanah
