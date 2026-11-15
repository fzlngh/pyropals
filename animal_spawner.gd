extends Node2D
@export var animal_scene: PackedScene
@export var spawn_points: Array[Marker2D] = []
@export var respawn_delay: float = 1.5  


func _ready() -> void:
	GameManager.animal_captured.connect(_on_animal_captured)

func _on_animal_captured(_total_captured: int) -> void:
	if GameManager.is_game_over:
		return 

	await get_tree().create_timer(respawn_delay).timeout
	_spawn_animal()
 

func _spawn_animal() -> void:
	if not animal_scene:
		push_warning("AnimalSpawner: 'Animal Scene' belum diisi di Inspector!")
		return
	if spawn_points.is_empty():
		push_warning("AnimalSpawner: 'Spawn Points' masih kosong, drag beberapa Marker2D ke situ!")
		return

	var point: Marker2D = spawn_points[randi() % spawn_points.size()]
	var inst := animal_scene.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_position = point.global_position
