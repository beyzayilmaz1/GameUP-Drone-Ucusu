extends Node2D

var hedef_can := 0.28
var can := 0.28
var _t := 0.0
var _yon := 1.0

func _process(delta: float) -> void:
	_t += delta
	can = move_toward(can, hedef_can, delta * 0.55)
	position.x += _yon * 42.0 * delta
	if position.x > 820.0:
		_yon = -1.0
	if position.x < 240.0:
		_yon = 1.0
	scale.x = _yon
	position.y = 250.0 + sin(_t * 0.8) * 16.0
	queue_redraw()

func _draw() -> void:
	var parlak := clampf((can - 0.2) / 0.8, 0.0, 1.0)
	var altin := Color("8d9a72").lerp(Color("ffb703"), parlak)
	altin.a = 0.55 + parlak * 0.45
	var mavi := Color("6f8f99").lerp(Color("4cc9f0"), parlak)
	mavi.a = altin.a
	var yerler: Array[Vector2] = [
		Vector2(0, 0), Vector2(28, 16), Vector2(-24, 12), Vector2(18, -18), Vector2(-8, 24),
	]
	for i in yerler.size():
		var o: Vector2 = yerler[i]
		var y := o.y + sin(_t * 3.0 + float(i)) * 6.0
		var renk := altin if i < 3 or can < 0.62 else mavi
		_balik(Vector2(o.x, y), renk, _t * 9.0 + float(i))

func _balik(o: Vector2, renk: Color, kuyruk: float) -> void:
	var sallan := Vector2(0, sin(kuyruk) * 3.0)
	var kuy := PackedVector2Array([
		o + Vector2(-9, 0),
		o + Vector2(-17, -5) + sallan,
		o + Vector2(-17, 5) - sallan,
	])
	draw_colored_polygon(kuy, renk)
	var govde := PackedVector2Array([
		o + Vector2(-7, 0),
		o + Vector2(3, -6),
		o + Vector2(13, 0),
		o + Vector2(3, 6),
	])
	draw_colored_polygon(govde, renk)
	draw_circle(o + Vector2(7, -1), 1.4, Color(0.1, 0.14, 0.18, renk.a))
