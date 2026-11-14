extends StaticBody2D

@export var is_hazard: bool = false

@onready var hazard_zone: Area2D = get_node_or_null("HazardZone")


func _ready() -> void: 
	add_to_group("obstacles")
	if is_hazard and hazard_zone:
		hazard_zone.body_entered.connect(_on_hazard_zone_body_entered)


func _on_hazard_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()

func despawn() -> void:
	queue_free()
