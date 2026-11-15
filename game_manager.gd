extends Node

signal animal_captured(total_captured: int)
signal life_changed(lives: int)
signal respawn_requested
signal session_won
signal session_lost

@export var target_capture_count: int = 1
@export var max_lives: int = 1

var captured_count: int = 0
var lives: int = 0
var is_game_over: bool = false


func reset_session() -> void:
	captured_count = 0
	lives = max_lives
	is_game_over = false
	life_changed.emit(lives)


func on_animal_captured(_animal: Node) -> void:
	if is_game_over:
		return
	captured_count += 1
	animal_captured.emit(captured_count)

	if captured_count >= target_capture_count:
		win_session()


func on_player_died() -> void:
	if is_game_over:
		return

	lives -= 1
	life_changed.emit(lives)

	if lives <= 0:
		is_game_over = true
		session_lost.emit()
		
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://bad_ending.tscn")
	else:
		await get_tree().create_timer(1.0).timeout
		respawn_requested.emit()


func win_session() -> void:
	is_game_over = true
	session_won.emit()
	get_tree().change_scene_to_file("res://good_ending.tscn")
