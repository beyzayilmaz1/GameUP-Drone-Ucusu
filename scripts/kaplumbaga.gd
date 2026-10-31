extends Node2D

var aktif := false
var _gorunen := 0.0
var _yon := 1.0
var _t := 0.0

func _ready() -> void:
	modulate.a = 0.0

func _process(delta: float) -> void:
	_t += delta
	var hedef := 1.0 if aktif else 0.0
	_gorunen = move_toward(_gorunen, hedef, delta * 0.55)
	modulate.a = _gorunen
	if _gorunen > 0.05:
		position.x += _yon * 34.0 * delta
		position.y = 490.0 + sin(_t * 0.7) * 18.0
		if position.x > 1080.0:
			_yon = -1.0
		if position.x < 180.0:
			_yon = 1.0
		scale.x = _yon
	queue_redraw()

func _draw() -> void:
	var flap := sin(_t * 3.2) * 8.0
	draw_circle(Vector2(16, -1), 7.0, Color("7dcea0"))
	draw_circle(Vector2(18, -3), 1.5, Color("17352f"))
	draw_line(Vector2(2, -8), Vector2(-6, -18.0 - flap), Color("5dbe90"), 4.0, true)
	draw_line(Vector2(2, 8), Vector2(-6, 18.0 + flap), Color("5dbe90"), 4.0, true)
	draw_circle(Vector2(-4, 0), 16.0, Color("1f8f78"))
	draw_circle(Vector2(-4, -3), 9.0, Color("8fd9c4"))
	draw_arc(Vector2(-4, 0), 7.0, 0.0, TAU, 14, Color("146454"), 1.5, true)
