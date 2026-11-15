extends CharacterBody2D
enum State { IN_FOREST, ALERT, FLEEING, JUMPING, LURED, CAPTURED }

@export var flee_speed: float = 140.0
@export var lured_speed: float = 100.0  
@export var detect_player_radius: float = 180.0
@export var gravity: float = 1200.0 

@export var jump_velocity: float = -380.0
@export var obstacle_ray_length: float = 36.0

var state: State = State.IN_FOREST
var player_ref: Node2D = null
var lure_target: Node2D = null       
var state_before_jump: State = State.FLEEING 

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
			_move_and_check_obstacle(delta, _flee_direction(), flee_speed, State.FLEEING)
		State.LURED:
			_move_and_check_obstacle(delta, _lure_direction(), lured_speed, State.LURED)
		State.JUMPING:
			_move_in_air(delta)
		State.CAPTURED:
			velocity = Vector2.ZERO

	if not is_on_floor() and state != State.CAPTURED:
		velocity.y += gravity * delta

	move_and_slide()

	if state == State.JUMPING and is_on_floor():
		state = state_before_jump
		anim.play("run_away")


func start_luring(cage: Node2D) -> void:
	if state == State.CAPTURED:
		return
	lure_target = cage
	state = State.LURED
	anim.play("run_away")  


func _flee_direction() -> float:
	if not player_ref:
		return 0.0
	var dir := signf(global_position.x - player_ref.global_position.x)
	return 1.0 if dir == 0.0 else dir


func _lure_direction() -> float:
	if not lure_target or not is_instance_valid(lure_target):
		state = State.FLEEING
		return 0.0
	var dir := signf(lure_target.global_position.x - global_position.x)
	return 1.0 if dir == 0.0 else dir

func _move_and_check_obstacle(_delta: float, dir: float, speed: float, current_state: State) -> void:
	if dir == 0.0:
		return

	velocity.x = dir * speed
	anim.flip_h = dir < 0.0

	obstacle_ray.target_position = Vector2(obstacle_ray_length * dir, 0)
	obstacle_ray.force_raycast_update()

	if is_on_floor() and obstacle_ray.is_colliding():
		var collider := obstacle_ray.get_collider()
		if collider and collider.is_in_group("obstacles"):
			velocity.y = jump_velocity
			state_before_jump = current_state
			state = State.JUMPING
			anim.play("jump")


func _move_in_air(_delta: float) -> void:
	var dir := _flee_direction() if state_before_jump == State.FLEEING else _lure_direction()
	if dir != 0.0:
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
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	if anim.sprite_frames and anim.sprite_frames.has_animation("captured"):
		anim.play("captured")
	else:
		var fade_tween := create_tween()
		fade_tween.tween_property(anim, "modulate:a", 0.0, 0.4)
		fade_tween.parallel().tween_property(anim, "scale", anim.scale * 0.5, 0.4)

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
