extends Node2D

@export var tur := "sise"
@export var faz_basi := 0.0

var toplanan := false
var vurgulu := false
var hareket := false
var akis := Vector2.ZERO
var _t := 0.0
var _yuva := Vector2.ZERO

func _ready() -> void:
	_yuva = position

func _process(delta: float) -> void:
	if toplanan:
		return
	_t += delta
	if hareket:
		position += akis * delta
		position.x += sin(_t * 1.4 + faz_basi) * 18.0 * delta
	else:
		position = _yuva + Vector2(sin(_t * 0.7 + faz_basi) * 16.0, cos(_t * 0.5 + faz_basi) * 10.0)
	queue_redraw()

func topla() -> void:
	toplanan = true
	visible = false

func _draw() -> void:
	if vurgulu:
		draw_arc(Vector2(0, 4), 26.0, 0.0, TAU, 24, Color("ffb15a"), 2.0, true)
	if tur == "poset":
		_poset()
	else:
		_sise()

func _sise() -> void:
	var govde := PackedVector2Array([
		Vector2(-8, -16), Vector2(8, -16), Vector2(10, 16), Vector2(-10, 16),
	])
	draw_colored_polygon(govde, Color(0.96, 0.98, 1, 0.94))
	draw_rect(Rect2(-4, -24, 8, 9), Color("3aa0d8"), true)
	draw_rect(Rect2(-8, -2, 16, 6), Color("2f6fed"), true)

func _poset() -> void:
	var e := sin(_t * 3.0 + faz_basi) * 2.0
	var poset := PackedVector2Array([
		Vector2(-13, -4 + e), Vector2(0, -16), Vector2(13, -3 - e), Vector2(8, 14), Vector2(-9, 12),
	])
	draw_colored_polygon(poset, Color(0.96, 0.58, 0.24, 0.94))
	draw_line(Vector2(-4, -12), Vector2(5, -12), Color("fff1dc"), 2.0, true)
