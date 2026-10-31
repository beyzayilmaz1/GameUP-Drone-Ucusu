extends Node2D

var metin := "+100"
var omur := 0.75
var renk := Color("ffe08a")

func _process(delta: float) -> void:
	position.y -= 48.0 * delta
	omur -= delta
	modulate.a = clampf(omur / 0.75, 0.0, 1.0)
	queue_redraw()
	if omur <= 0.0:
		queue_free()

func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(-28, 0), metin, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, renk)
