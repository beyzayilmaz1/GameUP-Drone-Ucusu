extends Node2D

var atik := 78.0
var oksijen := 58.0
var ekilen := 0
var _zaman := 0.0
var _kabarcik: Array[Vector2] = []
var _alg: Array[Vector2] = []

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261031
	for _i in 16:
		_kabarcik.append(Vector2(rng.randf_range(120.0, 1200.0), rng.randf_range(140.0, 600.0)))
	for i in 7:
		_alg.append(Vector2(180.0 + float(i) * 145.0, 628.0))

func _process(delta: float) -> void:
	_zaman += delta
	queue_redraw()

func _draw() -> void:
	var kirli := clampf(atik / 100.0, 0.0, 1.0)
	var can := clampf(oksijen / 100.0, 0.0, 1.0)
	_gokyuzu()
	var ust := Color("74863f").lerp(Color("19b4e6"), 1.0 - kirli)
	var dip := Color("2a331f").lerp(Color("083e78"), 1.0 - kirli)
	ust = ust.lerp(Color("1d4e5c"), (1.0 - can) * 0.45)
	dip = dip.lerp(Color("102028"), (1.0 - can) * 0.35)
	var serit := 24
	var ust_y := 108.0
	var alt_y := 618.0
	var yuk := (alt_y - ust_y) / float(serit)
	for i in serit:
		var u := float(i) / float(serit - 1)
		draw_rect(Rect2(0.0, ust_y + float(i) * yuk, 1280.0, yuk + 1.0), ust.lerp(dip, u), true)
	_yuzey()
	_isik(can)
	_boru()
	_bulanik()
	_algler()
	_kum()
	_kabarciklar(can)
	if oksijen > 72.0:
		var a := clampf((oksijen - 72.0) / 28.0, 0.0, 1.0)
		_denizanasi(Vector2(280.0, 210.0 + sin(_zaman) * 14.0), a)
		_denizanasi(Vector2(960.0, 360.0 + cos(_zaman * 0.8) * 12.0), a)

func _gokyuzu() -> void:
	for i in 6:
		var u := float(i) / 5.0
		draw_rect(Rect2(0.0, float(i) * 18.0, 1280.0, 20.0), Color("7ec8f0").lerp(Color("e9f8ff"), u), true)
	draw_circle(Vector2(860, 36), 18, Color("fff4c8"))
	draw_circle(Vector2(180, 28), 10, Color(1, 1, 1, 0.85))
	draw_circle(Vector2(198, 26), 14, Color(1, 1, 1, 0.9))
	draw_circle(Vector2(1040, 24), 12, Color(1, 1, 1, 0.8))
	draw_circle(Vector2(1058, 30), 16, Color(1, 1, 1, 0.88))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 96), Vector2(180, 78), Vector2(340, 100), Vector2(0, 108),
	]), Color("8fb8d4"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(980, 108), Vector2(1120, 82), Vector2(1280, 94), Vector2(1280, 108),
	]), Color("7eafcc"))

func _yuzey() -> void:
	draw_rect(Rect2(0, 102, 1280, 10), Color(1, 1, 1, 0.28), true)
	draw_line(Vector2(0, 108), Vector2(1280, 108), Color(1, 1, 1, 0.8), 2.0, true)
	for i in 18:
		var x := float(i) * 74.0 + sin(_zaman + float(i)) * 6.0
		draw_circle(Vector2(x, 112), 2.0, Color(1, 1, 1, 0.35))

func _isik(can: float) -> void:
	var a := 0.04 + can * 0.08
	for i in 3:
		var x0 := 220.0 + float(i) * 320.0
		var sail := PackedVector2Array([
			Vector2(x0, 108),
			Vector2(x0 + 36, 108),
			Vector2(x0 + 90, 600),
			Vector2(x0 + 10, 600),
		])
		draw_colored_polygon(sail, Color(0.9, 0.98, 1.0, a))

func _boru() -> void:
	draw_rect(Rect2(0, 108, 54, 28), Color("9aa7b2"), true)
	draw_rect(Rect2(36, 112, 28, 18), Color("6d7a86"), true)
	draw_circle(Vector2(64, 122), 8, Color("5c6a74"))

func _bulanik() -> void:
	var a := clampf(atik / 100.0, 0.0, 1.0)
	if a <= 0.02:
		return
	for i in 6:
		var p := Vector2(78.0 + float(i) * 10.0, 140.0 + float(i) * 36.0 + sin(_zaman + float(i)) * 6.0)
		draw_circle(p, 16.0 + float(i) * 4.0, Color(0.55, 0.58, 0.28, 0.16 * a))

func _algler() -> void:
	var oran := clampf(atik / 100.0, 0.0, 1.0)
	if oran < 0.08:
		return
	for i in _alg.size():
		var p: Vector2 = _alg[i]
		var r := (10.0 + float(i % 3) * 8.0) * oran
		var o := Vector2(sin(_zaman + float(i)) * 3.0, -4.0)
		draw_circle(p + o, r, Color(0.42, 0.48, 0.2, 0.38 * oran))

func _kum() -> void:
	draw_rect(Rect2(0, 618, 1280, 102), Color("e6d3a4"), true)
	draw_rect(Rect2(0, 618, 1280, 8), Color("f3e6c4"), true)
	for x in [160, 340, 590, 880, 1120]:
		draw_circle(Vector2(x, 650), 7, Color("d7c08a"))
		draw_circle(Vector2(x + 16, 662), 4, Color("c9b07a"))

func _kabarciklar(can: float) -> void:
	var ekstra := ekilen
	for i in _kabarcik.size():
		var kaynak: Vector2 = _kabarcik[i]
		var hiz := 22.0 + float(ekstra) * 10.0
		var by := fposmod(kaynak.y - _zaman * hiz, 500.0) + 120.0
		var alfa := 0.12 + can * 0.28
		draw_arc(Vector2(kaynak.x, by), 2.4 + float(i % 3), 0.0, TAU, 10, Color(1, 1, 1, alfa), 1.2, true)

func _denizanasi(p: Vector2, a: float) -> void:
	draw_circle(p, 11, Color(1.0, 0.72, 0.86, 0.22 + 0.4 * a))
	draw_circle(p + Vector2(-2, -2), 4, Color(1, 1, 1, 0.25 * a))
	for dx in [-5.0, 0.0, 5.0]:
		var uc := p + Vector2(dx, 24.0 + sin(_zaman * 2.0 + dx) * 4.0)
		draw_line(p + Vector2(dx * 0.4, 8), uc, Color(1.0, 0.8, 0.9, 0.45 * a), 1.4, true)
