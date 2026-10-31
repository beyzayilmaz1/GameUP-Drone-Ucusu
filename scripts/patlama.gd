extends Node2D

var renk := Color("ffe08a")
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t > 0.32:
		queue_free()

func _draw() -> void:
	var a := 1.0 - _t / 0.32
	for i in 8:
		var aci := float(i) / 8.0 * TAU
		var p := Vector2(cos(aci), sin(aci)) * (8.0 + _t * 90.0)
		draw_circle(p, 3.2 * a, Color(renk.r, renk.g, renk.b, a))
