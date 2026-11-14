extends CharacterBody2D
enum State { IN_FOREST, ALERT, FLEEING, JUMPING, CAPTURED }

@export var flee_speed: float = 140.0
@export var detect_player_radius: float = 180.0
@export var gravity: float = 1200.0

@export var jump_velocity: float = -380.0
@export var obstacle_ray_length: float = 36.0

var state: State = State.IN_FOREST
var player_ref: Node2D = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $Detect_area
@onready var obstacle_ray: RayCast2D = $ObstacleRay


func _ready() -> void:
	add_to_group("animals")
	detect_area.body_entered.connect(_on_detect_area_body_entered)
	anim.play("idle_forest")


func _physics_process(delta: float) -> void:
	match state:
		State.IN_FOREST, State.ALERT:
			velocity.x = 0.0
		State.FLEEING:
			_flee(delta)
		State.JUMPING:
			_flee_in_air(delta)
		State.CAPTURED:
			velocity = Vector2.ZERO

	if not is_on_floor() and state != State.CAPTURED:
		velocity.y += gravity * delta

	move_and_slide()

	if state == State.JUMPING and is_on_floor():
		state = State.FLEEING
		anim.play("run_away")


func _flee(_delta: float) -> void:
	if not player_ref:
		return

	var dir := signf(global_position.x - player_ref.global_position.x)
	if dir == 0.0:
		dir = 1.0
	velocity.x = dir * flee_speed
	anim.flip_h = dir < 0.0
	anim.play("run_away")

	obstacle_ray.target_position = Vector2(obstacle_ray_length * dir, 0)
	obstacle_ray.force_raycast_update()

	if is_on_floor() and obstacle_ray.is_colliding():
		var collider := obstacle_ray.get_collider()
		if collider and collider.is_in_group("obstacles"):
			velocity.y = jump_velocity
			state = State.JUMPING
			anim.play("jump")


func _flee_in_air(_delta: float) -> void:
	if not player_ref:
		return

	var dir := signf(global_position.x - player_ref.global_position.x)
	if dir == 0.0:
		dir = 1.0
	velocity.x = dir * flee_speed
	anim.flip_h = dir < 0.0


func _on_detect_area_body_entered(body: Node2D) -> void:
	if state == State.IN_FOREST and body.is_in_group("player"):
		player_ref = body
		state = State.ALERT
		anim.play("alert")
		await get_tree().create_timer(0.35).timeout
		if state == State.ALERT:
			state = State.FLEEING


func capture() -> void:
	if state == State.CAPTURED:
		return
	state = State.CAPTURED
	velocity = Vector2.ZERO
	anim.play("captured")
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	var tween := create_tween()
	tween.tween_interval(0.6)
	tween.tween_callback(func():
		GameManager.on_animal_captured(self)
		queue_free()
	)


func is_catchable() -> bool:
	return state != State.CAPTURED


func is_captured() -> bool:
	return state == State.CAPTURED
