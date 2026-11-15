extends CharacterBody2D
@export var speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0

@export var cage_scene: PackedScene
@export var cage_place_distance: float = 80.0

var is_dead: bool = false
var start_position: Vector2
var facing_dir: float = 1.0  

@onready var anim: AnimatedSprite2D = $animated
@onready var hurt_box: Area2D = $hurtbox

signal player_died
signal cage_used(global_pos: Vector2)

func _ready() -> void:
	add_to_group("player")

	hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	hurt_box.body_entered.connect(_on_hurt_box_body_entered)

	start_position = global_position
	player_died.connect(GameManager.on_player_died)
	GameManager.respawn_requested.connect(respawn)

	print("DEBUG: action 'use_cage' terdaftar di Input Map? -> ", InputMap.has_action("use_cage"))

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * speed
		anim.flip_h = direction < 0.0
		facing_dir = signf(direction)
		if is_on_floor():
			anim.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		if is_on_floor():
			anim.play("idle")

	# Lompat
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if not is_on_floor():
		anim.play("jump")

	move_and_slide()

	if InputMap.has_action("use_cage") and Input.is_action_just_pressed("use_cage"):
		_try_use_cage()

func _try_use_cage() -> void:
	var scene_to_use: PackedScene = cage_scene
	if not scene_to_use:
		scene_to_use = load("res://cage.tscn")
		if scene_to_use:
			print("DEBUG: 'Cage Scene' kosong di Inspector, pakai fallback res://cage.tscn")

	if not scene_to_use:
		push_warning("Player: Cage Scene kosong DAN res://cage.tscn tidak ditemukan!")
		return

	var cage := scene_to_use.instantiate()
	var place_pos := global_position + Vector2(cage_place_distance * facing_dir, 0)
	get_tree().current_scene.add_child(cage)
	cage.global_position = place_pos
	cage_used.emit(place_pos)
	print("DEBUG kandang ditaruh di: ", place_pos)


func respawn() -> void:
	is_dead = false
	global_position = start_position
	velocity = Vector2.ZERO
	anim.play("idle")
	set_physics_process(true)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	_check_animal_touch(area.get_parent())

func _on_hurt_box_body_entered(body: Node) -> void:
	_check_animal_touch(body)

func _check_animal_touch(node: Node) -> void:
	if is_dead:
		return
	if node and node.is_in_group("animals"):
		if node.has_method("is_captured") and node.is_captured():
			return
		die()

func die() -> void:
	is_dead = true
	anim.play("death")
	player_died.emit()
	set_physics_process(false)
