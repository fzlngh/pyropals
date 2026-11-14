extends CharacterBody2D

@export var speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var cage_range: float = 100.0

var is_dead: bool = false
@onready var anim: AnimatedSprite2D = $animated
@onready var hurt_box: Area2D = $hurtbox

signal player_died
signal cage_used(global_pos: Vector2)


func _ready() -> void:
	add_to_group("player")
	hurt_box.area_entered.connect(_on_hurtbox_area_entered)
	hurt_box.body_entered.connect(_on_hurtbox_body_entered)

	# Cek otomatis di panel Output kalau ada nama aksi Input Map yang belum dibuat
	for action in ["move_left", "move_right", "jump", "use_cage"]:
		if not InputMap.has_action(action):
			push_error("Action '" + action + "' belum ada di Project Settings -> Input Map!")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	_check_animal_touch(area.get_parent())


func _on_hurtbox_body_entered(body: Node2D) -> void:
	_check_animal_touch(body)


func _check_animal_touch(node: Node) -> void:
	if is_dead:
		return
	if node and node.is_in_group("animals"):
		if node.has_method("is_captured") and node.is_captured():
			return
		die()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * speed
		anim.flip_h = direction < 0.0
		if is_on_floor():
			anim.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		if is_on_floor():
			anim.play("idle")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if not is_on_floor():
		anim.play("jump")

	move_and_slide()

	if Input.is_action_just_pressed("use_cage"):
		_try_use_cage()


func _try_use_cage() -> void:
	var animals := get_tree().get_nodes_in_group("animals")
	var nearest: Node2D = null
	var nearest_dist := cage_range

	for a in animals:
		if a.has_method("is_catchable") and a.is_catchable():
			var dist := global_position.distance_to(a.global_position)
			if dist <= nearest_dist:
				nearest = a
				nearest_dist = dist

	if nearest:
		nearest.call("capture")
		cage_used.emit(global_position)


func die() -> void:
	is_dead = true
	anim.play("death")
	player_died.emit()
	set_physics_process(false)
