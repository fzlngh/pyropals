extends Node

signal animal_captured(total_captured: int)
signal session_won
signal session_lost

@export var target_capture_count: int = 50  # berapa hewan harus ditangkap buat menang

var captured_count: int = 0
var is_game_over: bool = false


func reset_session() -> void:
	captured_count = 0
	is_game_over = false


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
	is_game_over = true
	session_lost.emit()
	get_tree().paused = true


func win_session() -> void:
	is_game_over = true
	session_won.emit()
	get_tree().paused = true
