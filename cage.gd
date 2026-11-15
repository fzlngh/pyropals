extends Node2D
@export var armed: bool = true

@onready var lure_zone: Area2D = $LureZone
@onready var trap_zone: Area2D = $TrapZone


func _ready() -> void:
	add_to_group("cages")
	lure_zone.body_entered.connect(_on_lure_zone_body_entered)
	trap_zone.body_entered.connect(_on_trap_zone_body_entered)

func _draw() -> void:
	var w := 36.0
	var h := 48.0
	var rect := Rect2(Vector2(-w / 2.0, -h), Vector2(w, h))
	var wood_color := Color(0.36, 0.25, 0.12)
	draw_rect(rect, wood_color, false, 3.0)
	var bars := 4
	for i in range(bars):
		var x: float = -w / 2.0 + (w / float(bars - 1)) * i
		draw_line(Vector2(x, -h), Vector2(x, 0), wood_color, 3.0)


func _on_lure_zone_body_entered(body: Node) -> void:
	if not armed:
		return
	if body.is_in_group("animals") and body.has_method("start_luring"):
		body.call("start_luring", self)


func _on_trap_zone_body_entered(body: Node) -> void:
	if not armed:
		return
	if body.is_in_group("animals") and body.has_method("capture"):
		armed = false
		body.call("capture")

		await get_tree().create_timer(0.8).timeout
		queue_free()
