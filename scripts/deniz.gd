extends Node2D

## Kirlilik 100 iken deniz bulanık, 0 iken açık mavi.
## Balıklar temizlik arttıkça belirginleşir.

var kirlilik := 100.0
var _zaman := 0.0
var _lekeler: Array[Vector2] = []
var _kabarcik: Array[Vector2] = []
var _balik_x: Array[float] = [80.0, 360.0, 690.0, 980.0, 240.0]
var _balik_y: Array[float] = [200.0, 300.0, 460.0, 250.0, 560.0]
var _balik_hiz: Array[float] = [36.0, 48.0, 32.0, 52.0, 40.0]

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261031
	for _i in 24:
		_lekeler.append(Vector2(rng.randf_range(20.0, 1260.0), rng.randf_range(30.0, 700.0)))
	for _i in 10:
		_kabarcik.append(Vector2(rng.randf_range(40.0, 1240.0), rng.randf_range(0.0, 720.0)))

func _process(delta: float) -> void:
	_zaman += delta
	queue_redraw()

func _draw() -> void:
	var temizlik := clampf(1.0 - kirlilik / 100.0, 0.0, 1.0)
	var yuzey := Color("6d784c").lerp(Color("1c93c8"), temizlik)
	var dip := Color("2c3324").lerp(Color("06283f"), temizlik)
	var serit := 28
	var yuk := 720.0 / float(serit)
	for i in serit:
		var u := float(i) / float(serit - 1)
		draw_rect(Rect2(0.0, float(i) * yuk, 1280.0, yuk + 1.0), yuzey.lerp(dip, u), true)

	var isik := temizlik * 0.16
	for i in 4:
		var x0 := 140.0 + float(i) * 280.0
		var sail := PackedVector2Array([
			Vector2(x0, 0.0),
			Vector2(x0 + 64.0, 0.0),
			Vector2(x0 + 130.0, 720.0),
			Vector2(x0 + 16.0, 720.0),
		])
		draw_colored_polygon(sail, Color(0.9, 0.97, 1.0, isik))

	var bulut := clampf(kirlilik / 100.0, 0.0, 1.0)
	for i in _lekeler.size():
		var p: Vector2 = _lekeler[i]
		var kayma := Vector2(sin(_zaman + float(i)), cos(_zaman * 0.6 + float(i))) * 8.0
		draw_circle(p + kayma, 14.0 + float(i % 4) * 5.0, Color(0.62, 0.56, 0.3, 0.2 * bulut))

	for i in _balik_x.size():
		var x := fposmod(_balik_x[i] + _zaman * _balik_hiz[i], 1460.0) - 80.0
		var y := _balik_y[i] + sin(_zaman * 0.9 + float(i) * 1.3) * 10.0
		var alfa := 0.1 + temizlik * 0.9
		_ciz_balik(Vector2(x, y), Color(0.98, 0.8, 0.45, alfa))

	for i in _kabarcik.size():
		var kaynak: Vector2 = _kabarcik[i]
		var by := fposmod(kaynak.y - _zaman * 28.0, 760.0) - 20.0
		draw_arc(Vector2(kaynak.x, by), 3.2, 0.0, TAU, 12, Color(1, 1, 1, 0.28), 1.2, true)

	draw_rect(Rect2(0, 0, 1280, 28), Color(1, 1, 1, 0.05 + temizlik * 0.08), true)

func _ciz_balik(origin: Vector2, renk: Color) -> void:
	var govde := PackedVector2Array([
		origin + Vector2(-18, 0),
		origin + Vector2(8, -8),
		origin + Vector2(18, 0),
		origin + Vector2(8, 8),
	])
	var kuyruk := PackedVector2Array([
		origin + Vector2(-14, 0),
		origin + Vector2(-26, -7),
		origin + Vector2(-26, 7),
	])
	draw_colored_polygon(kuyruk, renk)
	draw_colored_polygon(govde, renk)
	draw_circle(origin + Vector2(10, -2), 1.5, Color(0.08, 0.12, 0.16, renk.a))
