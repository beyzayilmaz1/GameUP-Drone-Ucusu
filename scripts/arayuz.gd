extends Control

var atik := 78.0
var oksijen := 58.0
var balik := false
var yengec := false
var kaplumbaga := false
var mesaj := ""
var bitti := false
var kazandi := false
var menu := true
var dalga := 1
var saglik := 64.0
var enerji := 100.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if menu:
		draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.1, 0.16, 0.35), true)
		_kutu(Rect2(300, 210, 680, 250), 18.0, Color("0e3a4a"))
	elif bitti:
		draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.08, 0.12, 0.45), true)
		var kart := Color("12352d") if kazandi else Color("3a2424")
		_kutu(Rect2(330, 248, 620, 200), 16.0, kart)
	elif mesaj != "":
		_kutu(Rect2(340, 286, 600, 64), 12.0, Color(0.05, 0.14, 0.2, 0.82))

	_kutu(Rect2(16, 8, 290, 70), 10.0, Color(0.05, 0.12, 0.18, 0.82))
	_kutu(Rect2(318, 8, 290, 70), 10.0, Color(0.05, 0.12, 0.18, 0.82))
	_kutu(Rect2(620, 8, 380, 70), 10.0, Color(0.05, 0.12, 0.18, 0.82))
	_kutu(Rect2(1012, 8, 248, 70), 10.0, Color(0.05, 0.12, 0.18, 0.82))
	_kutu(Rect2(360, 674, 560, 32), 8.0, Color(0.05, 0.12, 0.18, 0.72))

	var atik_renk := Color("d06a4f").lerp(Color("7dcea0"), 1.0 - clampf(atik / 100.0, 0.0, 1.0))
	_cubuk(Rect2(32, 54, 190, 12), clampf(atik / 100.0, 0.0, 1.0), atik_renk)
	_cubuk(Rect2(334, 54, 190, 12), clampf(oksijen / 100.0, 0.0, 1.0), Color("49d6e8"))

	_tur_ikon(Vector2(812, 44), "balik", balik)
	_tur_ikon(Vector2(878, 44), "yengec", yengec)
	_tur_ikon(Vector2(948, 44), "kaplumbaga", kaplumbaga)

	var saglik_renk := Color("e05a4f")
	if saglik >= 75.0:
		saglik_renk = Color("3ddc97")
	elif saglik >= 45.0:
		saglik_renk = Color("49d6e8")
	_kutu(Rect2(16, 82, 980, 18), 7.0, Color(0.05, 0.12, 0.18, 0.78))
	_cubuk(Rect2(168, 85, 800, 12), clampf(saglik / 100.0, 0.0, 1.0), saglik_renk)
	draw_string(ThemeDB.fallback_font, Vector2(28, 96), "SAĞLIK", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.97, 1))
	_kutu(Rect2(1008, 82, 256, 18), 7.0, Color(0.05, 0.12, 0.18, 0.78))
	var enerji_renk := Color("49d6e8") if enerji > 25.0 else Color("e05a4f")
	_cubuk(Rect2(1088, 85, 160, 12), clampf(enerji / 100.0, 0.0, 1.0), enerji_renk)
	draw_string(ThemeDB.fallback_font, Vector2(1020, 96), "ENERJİ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.97, 1))

func _kutu(alan: Rect2, yaricap: float, renk: Color) -> void:
	var r := yaricap
	draw_rect(Rect2(alan.position.x + r, alan.position.y, alan.size.x - r * 2.0, alan.size.y), renk, true)
	draw_rect(Rect2(alan.position.x, alan.position.y + r, alan.size.x, alan.size.y - r * 2.0), renk, true)
	draw_circle(alan.position + Vector2(r, r), r, renk)
	draw_circle(alan.position + Vector2(alan.size.x - r, r), r, renk)
	draw_circle(alan.position + Vector2(r, alan.size.y - r), r, renk)
	draw_circle(alan.position + Vector2(alan.size.x - r, alan.size.y - r), r, renk)

func _cubuk(alan: Rect2, oran: float, dolu: Color) -> void:
	_kutu(alan, 6.0, Color(1, 1, 1, 0.14))
	var miktar := clampf(oran, 0.0, 1.0)
	if miktar <= 0.02:
		return
	var genislik := maxf(10.0, (alan.size.x - 6.0) * miktar)
	_kutu(Rect2(alan.position + Vector2(3, 3), Vector2(genislik, alan.size.y - 6.0)), 4.0, dolu)

func _damla(p: Vector2) -> void:
	draw_circle(p + Vector2(0, 2), 6, Color("49b6e8"))
	var uc := PackedVector2Array([p + Vector2(-5, 1), p + Vector2(0, -8), p + Vector2(5, 1)])
	draw_colored_polygon(uc, Color("49b6e8"))

func _baloncuk(p: Vector2) -> void:
	draw_arc(p, 6.0, 0.0, TAU, 14, Color("bff6ff"), 2.0, true)
	draw_circle(p + Vector2(-2, -2), 1.4, Color(1, 1, 1, 0.8))

func _tur_ikon(p: Vector2, tur: String, acik: bool) -> void:
	var renk := Color(1, 1, 1, 0.28)
	if acik and tur == "balik":
		renk = Color("ffb703")
	elif acik and tur == "yengec":
		renk = Color("e3644f")
	elif acik and tur == "kaplumbaga":
		renk = Color("2a9d8f")
	draw_circle(p, 18, Color(1, 1, 1, 0.08))
	if tur == "balik":
		var govde := PackedVector2Array([
			p + Vector2(-8, 0), p + Vector2(2, -5), p + Vector2(9, 0), p + Vector2(2, 5),
		])
		draw_colored_polygon(govde, renk)
		draw_colored_polygon(PackedVector2Array([
			p + Vector2(-6, 0), p + Vector2(-12, -4), p + Vector2(-12, 4),
		]), renk)
	elif tur == "yengec":
		draw_circle(p, 6, renk)
		draw_circle(p + Vector2(-7, -3), 2.4, renk)
		draw_circle(p + Vector2(7, -3), 2.4, renk)
	else:
		draw_circle(p + Vector2(-2, 1), 7, renk)
		draw_circle(p + Vector2(7, 0), 3, renk)
