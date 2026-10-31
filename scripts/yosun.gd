extends Node2D

var ekili := false
var vurgulu := false
var boy := 0.0
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	var hedef := 1.0 if ekili else 0.0
	boy = move_toward(boy, hedef, delta * 1.8)
	queue_redraw()

func ek() -> void:
	ekili = true

func _draw() -> void:
	var halka := Color(1, 1, 1, 0.55)
	if vurgulu:
		halka = Color("7dffa8")
	draw_arc(Vector2(0, -4), 24.0, 0.0, TAU, 28, halka, 2.0, true)
	if boy <= 0.02:
		return
	for i in 6:
		var x := -18.0 + float(i) * 7.2
		var h := (22.0 + float(i % 3) * 16.0) * boy
		var eg := sin(_t * 2.1 + float(i)) * 8.0 * boy
		draw_line(Vector2(x, -6), Vector2(x + eg, -6.0 - h), Color("14924c"), 3.2, true)
		draw_line(Vector2(x, -6), Vector2(x + eg * 0.55, -6.0 - h * 0.72), Color("b6ffd8"), 1.3, true)
