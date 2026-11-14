extends Node2D

@export var rock_scene: PackedScene
@export var log_scene: PackedScene
@export var helicopter_scene: PackedScene

@export var min_spawn_interval: float = 1.5
@export var max_spawn_interval: float = 3.5

@export_range(0.0, 1.0, 0.05) var helicopter_chance: float = 0.3

@export var spawn_distance_ahead: Vector2 = Vector2(450, 750)

@export var ground_y: float = 280.0

@export var helicopter_y_range: Vector2 = Vector2(60, 160)

@export var helicopter_horizontal_range: float = 700.0

var player_ref: Node2D = null
var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	_schedule_next_spawn()

func set_player(p: Node2D) -> void:
	player_ref = p


func _schedule_next_spawn() -> void:
	_timer.start(randf_range(min_spawn_interval, max_spawn_interval))


func _on_timer_timeout() -> void:
	_spawn_random_obstacle()
	_schedule_next_spawn()


func _spawn_random_obstacle() -> void:
	if not player_ref:
		return  

	if randf() < helicopter_chance and helicopter_scene:
		_spawn_helicopter()
	else:
		_spawn_ground_obstacle()


func _spawn_ground_obstacle() -> void:
	var use_log := randf() < 0.5
	var scene: PackedScene = log_scene if use_log else rock_scene
	if not scene:
		return

	var inst := scene.instantiate()
	var ahead := randf_range(spawn_distance_ahead.x, spawn_distance_ahead.y)
	inst.global_position = Vector2(player_ref.global_position.x + ahead, ground_y)
	get_tree().current_scene.add_child(inst)


func _spawn_helicopter() -> void:
	if not helicopter_scene:
		return

	var inst := helicopter_scene.instantiate()
	var dir: int = 1 if randf() < 0.5 else -1
	var spawn_x: float
	var despawn_x: float

	if dir == -1:
		spawn_x = player_ref.global_position.x + helicopter_horizontal_range
		despawn_x = player_ref.global_position.x - helicopter_horizontal_range
	else:
		spawn_x = player_ref.global_position.x - helicopter_horizontal_range
		despawn_x = player_ref.global_position.x + helicopter_horizontal_range

	var fly_y := randf_range(helicopter_y_range.x, helicopter_y_range.y)
	inst.global_position = Vector2(spawn_x, fly_y)
	inst.direction = dir
	inst.despawn_x = despawn_x
	get_tree().current_scene.add_child(inst)
