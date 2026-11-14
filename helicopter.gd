extends Node2D

@export var speed: float = 160.0
@export var direction: int = -1 

var despawn_x: float = -300.0

@onready var sprite: AnimatedSprite2D = get_node_or_null("HeliSprite")
@onready var hazard_zone: Area2D = $HazardZone


func _ready() -> void:
	add_to_group("obstacles")
	if sprite:
		sprite.flip_h = direction > 0
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("fly"):
			sprite.play("fly")
	hazard_zone.body_entered.connect(_on_hazard_zone_body_entered)


func _process(delta: float) -> void:
	position.x += direction * speed * delta

	if direction < 0 and position.x < despawn_x:
		queue_free()
	elif direction > 0 and position.x > despawn_x:
		queue_free()


func _on_hazard_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()
