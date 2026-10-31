extends CharacterBody2D

const HIZ := 360.0

var halka := Color(1, 1, 1, 0.28)
var zipla := 0.0
var _rotor := 0.0
var _t := 0.0
var _yon := 1.0

func _physics_process(delta: float) -> void:
	var yon := Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		yon.x += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		yon.x -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		yon.y += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		yon.y -= 1.0
	var el := get_tree().get_first_node_in_group("dokun")
	if el != null:
		yon += el.cikis
	var oyun = get_parent()
	if oyun != null and oyun.otonom and oyun.enerji > 0.0:
		var hedef: Node2D = null
		var en := 99999.0
		for parca in oyun.atiklar:
			if parca.toplanan:
				continue
			var mesafe: float = global_position.distance_to(parca.global_position)
			if mesafe < en:
				en = mesafe
				hedef = parca
		if hedef != null:
			yon += (hedef.global_position - global_position).normalized()
	elif oyun != null and oyun.git_sure > 0.0 and oyun.enerji > 0.0:
		var fark: Vector2 = oyun.gidilecek - global_position
		if fark.length() > 10.0:
			yon += fark.normalized()
	yon = yon.limit_length(1.0)
	if zipla > 0.0:
		zipla = maxf(0.0, zipla - delta)
	var carpan := 1.0
	if oyun != null and oyun.enerji <= 0.0:
		carpan = 0.32
	velocity = yon * HIZ * carpan
	move_and_slide()
	position.x = clamp(position.x, 70.0, 1210.0)
	position.y = clamp(position.y, 150.0, 640.0)
	if abs(velocity.x) > 12.0:
		_yon = 1.0 if velocity.x > 0.0 else -1.0
	scale.x = _yon
	_t += delta
	_rotor += delta * (14.0 + yon.length() * 18.0)
	queue_redraw()

func _draw() -> void:
	var buyume := 1.0 + zipla * 1.6
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(buyume, buyume))
	draw_arc(Vector2.ZERO, 52.0, 0.0, TAU, 36, halka, 2.2, true)
	var oyun = get_parent()
	if oyun != null:
		var oran := clampf(float(oyun.enerji) / 100.0, 0.0, 1.0)
		var erenk := Color("49d6e8") if oran > 0.25 else Color("e05a4f")
		draw_arc(Vector2.ZERO, 44.0, -PI / 2.0, -PI / 2.0 + TAU * oran, 28, erenk, 3.0, true)
		if float(oyun.sonar_sure) > 0.0:
			var acilim := (1.0 - float(oyun.sonar_sure) / 4.0) * 260.0
			draw_arc(Vector2.ZERO, 70.0 + acilim, 0.0, TAU, 40, Color(0.4, 0.95, 1.0, 0.35), 2.0, true)
	draw_set_transform(Vector2(0, 22), 0.0, Vector2(1.15, 0.32))
	draw_circle(Vector2.ZERO, 16.0, Color(0, 0, 0, 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(buyume, buyume))

	var govde := PackedVector2Array([
		Vector2(-30, -11),
		Vector2(8, -15),
		Vector2(28, -6),
		Vector2(32, 5),
		Vector2(6, 13),
		Vector2(-30, 11),
		Vector2(-36, 0),
	])
	draw_colored_polygon(govde, Color("f5fbff"))
	draw_line(Vector2(-18, -6), Vector2(16, -6), Color("3ec6ff"), 4.0, true)
	draw_circle(Vector2(14, -1), 6.5, Color("d7f4ff"))
	draw_circle(Vector2(16, -1), 3.2, Color("163044"))
	draw_circle(Vector2(17.2, -2.4), 1.2, Color("ffffff"))

	var pervane := Vector2(-32, -2)
	var uc := pervane + Vector2(cos(_rotor), sin(_rotor)) * 13.0
	draw_line(pervane, uc, Color("9adfff"), 3.0, true)
	draw_circle(pervane, 3.0, Color("3ec6ff"))

	if velocity.length() > 20.0:
		for i in 3:
			var by := fposmod(_t * 46.0 + float(i) * 14.0, 34.0)
			draw_arc(Vector2(-8.0 - float(i) * 4.0, 12.0 - by), 2.2, 0.0, TAU, 8, Color(1, 1, 1, 0.45), 1.2, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
