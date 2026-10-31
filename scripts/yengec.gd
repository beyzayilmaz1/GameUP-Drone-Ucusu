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
	_gorunen = move_toward(_gorunen, hedef, delta * 0.8)
	modulate.a = _gorunen
	if _gorunen > 0.05:
		position.x += _yon * 26.0 * delta
		if position.x > 1120.0:
			_yon = -1.0
		if position.x < 160.0:
			_yon = 1.0
		scale.x = _yon
	queue_redraw()

func _draw() -> void:
	var adim := sin(_t * 8.0) * 3.0
	for i in 3:
		var s := -1.0 if i % 2 == 0 else 1.0
		var y0 := -2.0 + float(i) * 4.0
		draw_line(Vector2(-6, y0), Vector2(-15, y0 + 5.0 + adim * s), Color("c4493a"), 2.0, true)
		draw_line(Vector2(6, y0), Vector2(15, y0 + 5.0 - adim * s), Color("c4493a"), 2.0, true)
	draw_circle(Vector2(0, 2), 11, Color("e3644f"))
	draw_circle(Vector2(0, 0), 8, Color("f09484"))
	draw_circle(Vector2(-13, -6), 4.2, Color("ffc2b4"))
	draw_circle(Vector2(13, -6), 4.2, Color("ffc2b4"))
	draw_circle(Vector2(-3, -6), 1.7, Color("2b1d1a"))
	draw_circle(Vector2(3, -6), 1.7, Color("2b1d1a"))
