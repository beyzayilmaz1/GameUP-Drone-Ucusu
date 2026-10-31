extends Control

var cikis := Vector2.ZERO
var parmak := -1
var merkez := Vector2(118, 560)
var dugme := Vector2(1160, 560)
const YARICAP := 68.0

func _ready() -> void:
	add_to_group("dokun")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_right = 1280.0
	offset_bottom = 720.0

func _input(event: InputEvent) -> void:
	var oyun = get_parent().get_parent()
	if event is InputEventScreenTouch:
		var dokunus := event as InputEventScreenTouch
		if dokunus.pressed and not oyun.oynaniyor and not oyun.bitti:
			oyun._baslat()
			return
		if dokunus.pressed and dokunus.position.distance_to(Vector2(1188, 132)) < 26.0:
			oyun._ses_ac_kapa()
			return
		if dokunus.pressed and dokunus.position.distance_to(dugme) < 46.0 and oyun.oynaniyor:
			oyun._yosun_ek()
			return
		if dokunus.pressed and dokunus.position.x < 340.0 and parmak == -1:
			parmak = dokunus.index
			_guncelle(dokunus.position)
		elif not dokunus.pressed and dokunus.index == parmak:
			parmak = -1
			cikis = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag:
		var surukleme := event as InputEventScreenDrag
		if surukleme.index == parmak:
			_guncelle(surukleme.position)
	elif event is InputEventMouseButton:
		var tik := event as InputEventMouseButton
		if not tik.pressed:
			if parmak == -2:
				parmak = -1
				cikis = Vector2.ZERO
				queue_redraw()
			return
		if not oyun.oynaniyor and not oyun.bitti:
			oyun._baslat()
			return
		if tik.position.distance_to(Vector2(1188, 132)) < 26.0:
			oyun._ses_ac_kapa()
			return
		if tik.position.distance_to(dugme) < 46.0:
			oyun._yosun_ek()
			return
		if tik.position.x < 340.0:
			parmak = -2
			_guncelle(tik.position)
	elif event is InputEventMouseMotion and parmak == -2:
		var gez := event as InputEventMouseMotion
		_guncelle(gez.position)

func _guncelle(p: Vector2) -> void:
	var f := p - merkez
	if f.length() > YARICAP:
		f = f.limit_length(YARICAP)
	cikis = f / YARICAP
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(merkez, YARICAP, Color(1, 1, 1, 0.08))
	draw_arc(merkez, YARICAP, 0.0, TAU, 32, Color(1, 1, 1, 0.28), 2.0, true)
	draw_circle(merkez + cikis * YARICAP, 22.0, Color(1, 1, 1, 0.35))
	draw_circle(dugme, 40.0, Color(0.15, 0.55, 0.4, 0.55))
	draw_string(ThemeDB.fallback_font, dugme + Vector2(-10, 6), "G", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1, 1, 1, 0.95))
	draw_circle(Vector2(1188, 132), 16.0, Color(1, 1, 1, 0.16))
	draw_string(ThemeDB.fallback_font, Vector2(1180, 138), "M", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.9))
