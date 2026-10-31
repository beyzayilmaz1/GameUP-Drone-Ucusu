extends Node2D

## Dalga dalga gelen atık çekilir. Yosun oksijen üretir.
## Kombo puanı büyütür. Üç dalga ve yaşayan koy kazanır.

const HEDEF: Array = [5, 6, 8]

var atik := 70.0
var oksijen := 64.0
var puan := 0
var combo := 1
var combo_sure := 0.0
var toplanan := 0
var dalga_toplanan := 0
var ekilen := 0
var dalga := 1
var sure := 150.0
var bitti := false
var kazandi := false
var oynaniyor := false
var balik_acik := false
var yengec_acik := false
var kaplumbaga_acik := false
var tur_sayisi := 0

var atiklar: Array = []
var yosunlar: Array = []
var _duyuru_sure := 0.0
var _tur_hazir := false
var _dalga_arasi := 0.0
var _dalga_bekliyor := false
var _uyardi := false
var _sarsinti := 0.0
var _spawn := 0.8
var enerji := 100.0
var otonom := false
var sonar_sure := 0.0
var git_sure := 0.0
var gidilecek := Vector2.ZERO
var saglik := 64.0

@onready var drone: CharacterBody2D = $Drone
@onready var dunya = $Dunya
@onready var suru = $Suru
@onready var yengec = $Yengec
@onready var kaplumbaga = $Kaplumbaga
@onready var arayuz = $HUD/Arayuz
var kamera: Camera2D
var ses: Node
var dokun: Control

func _ready() -> void:
	for dugum in $Atiklar.get_children():
		atiklar.append(dugum)
	for dugum in $Yosunlar.get_children():
		yosunlar.append(dugum)
	kamera = Camera2D.new()
	kamera.position = Vector2(640, 360)
	add_child(kamera)
	kamera.make_current()
	ses = Node.new()
	ses.set_script(load("res://scripts/ses.gd"))
	add_child(ses)
	dokun = Control.new()
	dokun.set_script(load("res://scripts/dokun.gd"))
	$HUD.add_child(dokun)
	$HUD/Bitis.visible = true
	$HUD/Bitis.text = "Süzgeç Koyu\nTıkla, sonar kullan ya da drone'u kendin sür\nSPACE veya ekrana dokun"
	_yaz()

func _baslat() -> void:
	if oynaniyor or bitti:
		return
	oynaniyor = true
	$HUD/Bitis.visible = false
	for parca in atiklar:
		parca.hareket = true
		if parca.akis == Vector2.ZERO:
			parca.akis = Vector2(randf_range(34.0, 58.0), randf_range(6.0, 14.0))
	_duyur("Dalga 1")

func _ses_ac_kapa() -> void:
	if ses != null:
		ses.ac_kapa()
		_duyur("Ses açık" if ses.acik else "Ses kapalı")

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var tus := event as InputEventKey
	if not tus.pressed or tus.echo:
		return
	if tus.keycode == KEY_R:
		get_tree().reload_current_scene()
		return
	if tus.keycode == KEY_M:
		_ses_ac_kapa()
		return
	if bitti:
		return
	if not oynaniyor:
		if tus.keycode == KEY_SPACE or tus.keycode == KEY_ENTER:
			_baslat()
		return
	if tus.keycode == KEY_SPACE:
		_space()
	elif tus.keycode == KEY_G:
		_yosun_ek()
	elif tus.keycode == KEY_Q:
		_sonar()
	elif tus.keycode == KEY_T:
		_otonom()
	elif tus.keycode == KEY_E:
		_enerji_dolum()

func _process(delta: float) -> void:
	if oynaniyor and not bitti:
		sure = maxf(0.0, sure - delta)
		if combo_sure > 0.0:
			combo_sure -= delta
			if combo_sure <= 0.0:
				combo = 1
		_ekoloji(delta)
		_enerji(delta)
		_uret(delta)
		_em()
		_vurgula()
		_turleri()
		_dalga_kontrol(delta)
		if oksijen <= 0.0 or sure <= 0.0:
			_bitir(false)
	if _sarsinti > 0.0:
		_sarsinti = maxf(0.0, _sarsinti - delta * 10.0)
		kamera.offset = Vector2(randf_range(-_sarsinti, _sarsinti), randf_range(-_sarsinti, _sarsinti))
	else:
		kamera.offset = Vector2.ZERO
	if _duyuru_sure > 0.0:
		_duyuru_sure -= delta
		$HUD/Duyuru.visible = _duyuru_sure > 0.0
	_yaz()

func _ekoloji(delta: float) -> void:
	var baski := 0.0
	if atik > 55.0:
		baski = 0.7 + float(dalga) * 0.22
	elif atik > 30.0:
		baski = 0.25
	oksijen = clampf(oksijen + (float(ekilen) * 7.0 - baski) * delta, 0.0, 100.0)
	if ekilen > 0 and atik > 0.0:
		atik = maxf(0.0, atik - float(ekilen) * 0.8 * delta)

func _enerji(delta: float) -> void:
	if sonar_sure > 0.0:
		sonar_sure = maxf(0.0, sonar_sure - delta)
	if git_sure > 0.0:
		git_sure = maxf(0.0, git_sure - delta)
		enerji = maxf(0.0, enerji - 4.0 * delta)
	if drone.velocity.length() > 24.0:
		enerji = maxf(0.0, enerji - 5.0 * delta)
	if otonom:
		enerji = maxf(0.0, enerji - 8.0 * delta)
		if enerji <= 0.0:
			otonom = false
			_duyur("Enerji bitti, otonom kapandı")
	if _yosun_yaninda():
		enerji = minf(100.0, enerji + 22.0 * delta)

func _yosun_yaninda() -> bool:
	for yer in yosunlar:
		if yer.ekili and drone.global_position.distance_to(yer.global_position) < 96.0:
			return true
	return false

func _sonar() -> void:
	if enerji < 15.0:
		if ses != null:
			ses.cal("hata", 0.8)
		_duyur("Sonar için enerji yetmiyor")
		return
	enerji -= 15.0
	sonar_sure = 4.0
	if ses != null:
		ses.cal("puan", 0.75)
	_duyur("Sonar tarandı")

func _otonom() -> void:
	if not otonom and enerji < 8.0:
		_duyur("Otonom için enerji gerek")
		return
	otonom = not otonom
	_duyur("Otonom açık" if otonom else "Otonom kapalı")

func _enerji_dolum() -> void:
	if puan < 100:
		_duyur("Dolum 100 puan")
		return
	if enerji > 92.0:
		return
	puan -= 100
	enerji = minf(100.0, enerji + 45.0)
	if ses != null:
		ses.cal("yosun", 1.2)
	_duyur("Enerji doldu")

func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or not oynaniyor or bitti:
		return
	var tik := event as InputEventMouseButton
	if not tik.pressed or tik.button_index != MOUSE_BUTTON_LEFT:
		return
	var m := get_global_mouse_position()
	if m.y < 108.0 or m.y > 650.0:
		return
	if m.distance_to(Vector2(1160, 560)) < 52.0:
		return
	if m.x < 200.0 and m.y > 480.0:
		return
	var secilen = null
	var en_yakin := 46.0
	for parca in atiklar:
		if parca.toplanan:
			continue
		var d := m.distance_to(parca.global_position)
		if d < en_yakin:
			en_yakin = d
			secilen = parca
	if secilen != null and drone.global_position.distance_to(secilen.global_position) < 150.0 and enerji >= 6.0:
		enerji -= 6.0
		_topla(secilen)
	else:
		gidilecek = secilen.global_position if secilen != null else m
		git_sure = 2.4
	get_viewport().set_input_as_handled()

func _uret(delta: float) -> void:
	if _dalga_arasi > 0.0 or dalga_toplanan >= int(HEDEF[dalga - 1]):
		return
	var aktif := 0
	for parca in atiklar:
		if not parca.toplanan:
			aktif += 1
	if aktif >= 5:
		return
	_spawn -= delta
	if _spawn > 0.0:
		return
	_spawn = 2.2 - float(dalga) * 0.38
	_yeni_atik(Vector2(86.0, randf_range(155.0, 230.0)))

func _yeni_atik(pos: Vector2) -> void:
	var n := Node2D.new()
	n.set_script(load("res://scripts/atik.gd"))
	n.position = pos
	n.tur = "poset" if randi() % 2 == 0 else "sise"
	n.faz_basi = randf() * TAU
	$Atiklar.add_child(n)
	n.akis = Vector2(randf_range(52.0, 98.0), randf_range(12.0, 34.0))
	n.hareket = true
	atiklar.append(n)

func _em() -> void:
	for parca in atiklar:
		if parca.toplanan:
			continue
		if parca.position.y > 608.0:
			parca.topla()
			atik = minf(100.0, atik + 12.0)
			_sarsinti = 5.0
			_patla(parca.global_position, Color("c4784a"))
			if ses != null:
				ses.cal("hata")
			_duyur("Atık dibe çöktü")
			continue
		if not parca.hareket:
			continue
		var d := drone.global_position.distance_to(parca.global_position)
		if d < 96.0:
			parca.global_position = parca.global_position.move_toward(drone.global_position, 260.0 * get_process_delta_time())
		if d < 30.0:
			_topla(parca)

func _space() -> void:
	for parca in atiklar:
		if parca.toplanan:
			continue
		if drone.global_position.distance_to(parca.global_position) < 78.0:
			_topla(parca)
			return
	if ses != null:
		ses.cal("hata", 0.8)
	_duyur("Yakında atık yok")

func _topla(parca) -> void:
	if parca.toplanan:
		return
	parca.topla()
	if combo_sure > 0.0:
		combo = mini(combo + 1, 8)
	else:
		combo = 1
	combo_sure = 2.3
	var kazanc := 100 * combo
	puan += kazanc
	toplanan += 1
	dalga_toplanan += 1
	atik = maxf(0.0, atik - 8.0)
	drone.zipla = 0.16
	_sarsinti = 2.0 + float(combo)
	_yazi(parca.global_position, "+%d" % kazanc, Color("ffe08a"))
	_patla(parca.global_position, Color("fff1c4"))
	if ses != null:
		ses.cal("topla", 1.0 + float(combo - 1) * 0.07)
	if combo == 3 or combo == 5:
		_duyur("Kombo x%d" % combo)
		if ses != null:
			ses.cal("puan", 1.15)

func _yosun_ek() -> void:
	if not oynaniyor or bitti:
		return
	var secilen = null
	var mesafe := 84.0
	for yer in yosunlar:
		if yer.ekili:
			continue
		var d := drone.global_position.distance_to(yer.global_position)
		if d < mesafe:
			mesafe = d
			secilen = yer
	if secilen == null:
		if ses != null:
			ses.cal("hata", 0.85)
		_duyur("Halkanın üstüne gel")
		return
	secilen.ek()
	ekilen += 1
	puan += 200
	_yazi(secilen.global_position, "+200", Color("9dffc4"))
	_patla(secilen.global_position, Color("7dffa8"))
	_sarsinti = 3.0
	if ses != null:
		ses.cal("yosun")
	_duyur("Yosun tutundu")

func _vurgula() -> void:
	for yer in yosunlar:
		yer.vurgulu = false
	var hedef = null
	var mesafe := 96.0
	for parca in atiklar:
		parca.vurgulu = false
		if parca.toplanan:
			continue
		var d := drone.global_position.distance_to(parca.global_position)
		if d < mesafe:
			mesafe = d
			hedef = parca
	if sonar_sure > 0.0:
		for parca in atiklar:
			if not parca.toplanan:
				parca.vurgulu = true
	if hedef != null:
		hedef.vurgulu = true
		drone.halka = Color("ffb15a")
		drone.queue_redraw()
		return
	var halka = null
	mesafe = 84.0
	for yer in yosunlar:
		if yer.ekili:
			continue
		var d2 := drone.global_position.distance_to(yer.global_position)
		if d2 < mesafe:
			mesafe = d2
			halka = yer
	if halka != null:
		halka.vurgulu = true
		drone.halka = Color("7dffa8")
	else:
		drone.halka = Color(1, 1, 1, 0.28)
	drone.queue_redraw()

func _turleri() -> void:
	var balik := atik < 62.0
	var yengec_var := atik < 48.0 and ekilen >= 1 and oksijen > 42.0
	var kaplumbaga_var := atik < 32.0 and ekilen >= 2 and oksijen > 58.0
	if _tur_hazir and oynaniyor:
		if balik and not balik_acik:
			_duyur("Balıklar canlandı")
			_odul_tur()
		if yengec_var and not yengec_acik:
			_duyur("Yeni tür: yengeç")
			_odul_tur()
		if kaplumbaga_var and not kaplumbaga_acik:
			_duyur("Yeni tür: kaplumbağa")
			_odul_tur()
	balik_acik = balik
	yengec_acik = yengec_var
	kaplumbaga_acik = kaplumbaga_var
	tur_sayisi = int(balik) + int(yengec_var) + int(kaplumbaga_var)
	suru.hedef_can = 1.0 if balik else 0.28
	yengec.aktif = yengec_var
	kaplumbaga.aktif = kaplumbaga_var
	_tur_hazir = true

func _odul_tur() -> void:
	puan += 300
	_sarsinti = 4.0
	if ses != null:
		ses.cal("tur")

func _dalga_kontrol(delta: float) -> void:
	var hedef := int(HEDEF[dalga - 1])
	if _dalga_arasi > 0.0:
		_dalga_arasi -= delta
		if _dalga_arasi <= 0.0:
			dalga += 1
			dalga_toplanan = 0
			_dalga_bekliyor = false
			_uyardi = false
			_spawn = 0.4
			for parca in atiklar:
				if not parca.toplanan and not parca.hareket:
					parca.hareket = true
					parca.akis = Vector2(randf_range(40.0, 70.0), randf_range(8.0, 20.0))
			_duyur("Dalga %d" % dalga)
		return
	if dalga_toplanan < hedef:
		return
	if dalga >= 3:
		if ekilen >= 1 and oksijen >= 40.0:
			_bitir(true)
		elif not _uyardi:
			_uyardi = true
			_duyur("Yosun ekle, oksijen kalsın")
		return
	_dalga_bekliyor = true
	_dalga_arasi = 1.5
	puan += 250
	_yazi(drone.global_position + Vector2(0, -30), "+250", Color("fff6c8"))
	if ses != null:
		ses.cal("puan")
	_duyur("Dalga %d temiz" % dalga)

func _bitir(basardi: bool) -> void:
	if bitti:
		return
	bitti = true
	kazandi = basardi
	$HUD/Duyuru.visible = false
	_duyuru_sure = 0.0
	$HUD/Bitis.visible = true
	if basardi:
		$HUD/Bitis.text = "Koy canlandı\nPuan %d\nR ile yeniden" % puan
		if ses != null:
			ses.cal("kazan")
	elif oksijen <= 0.0:
		$HUD/Bitis.text = "Oksijen bitti\nPuan %d\nR ile yeniden" % puan
		if ses != null:
			ses.cal("kaybet")
	else:
		$HUD/Bitis.text = "Süre doldu\nPuan %d\nR ile yeniden" % puan
		if ses != null:
			ses.cal("kaybet")

func _duyur(metin: String) -> void:
	if bitti:
		return
	$HUD/Duyuru.text = metin
	$HUD/Duyuru.visible = true
	_duyuru_sure = 1.8

func _yazi(pos: Vector2, metin: String, renk: Color) -> void:
	var n := Node2D.new()
	n.set_script(load("res://scripts/yazi.gd"))
	n.position = pos
	add_child(n)
	n.metin = metin
	n.renk = renk

func _patla(pos: Vector2, renk: Color) -> void:
	var n := Node2D.new()
	n.set_script(load("res://scripts/patlama.gd"))
	n.position = pos
	add_child(n)
	n.renk = renk

func _yaz() -> void:
	$HUD/AtikDurum.text = _atik_soz()
	$HUD/AtikSayi.text = str(int(round(atik)))
	$HUD/O2Durum.text = _o2_soz()
	$HUD/O2Sayi.text = str(int(round(oksijen)))
	var hedef_kg := int(HEDEF[dalga - 1])
	$HUD/CanBaslik.text = "MARMARA  %d/%d kg" % [dalga_toplanan, hedef_kg]
	$HUD/CanDeger.text = "%d/3" % tur_sayisi
	saglik = _saglik()
	$HUD/Ipucu.text = _tavsiye()
	var sn := int(ceil(sure))
	if combo > 1 and combo_sure > 0.0:
		$HUD/SureBaslik.text = "KOMBO x%d" % combo
	else:
		$HUD/SureBaslik.text = "PUAN    %d:%02d" % [int(sn / 60), sn % 60]
	$HUD/SureDeger.text = str(puan)
	dunya.atik = atik
	dunya.oksijen = oksijen
	dunya.ekilen = ekilen
	arayuz.atik = atik
	arayuz.oksijen = oksijen
	arayuz.balik = balik_acik
	arayuz.yengec = yengec_acik
	arayuz.kaplumbaga = kaplumbaga_acik
	arayuz.mesaj = $HUD/Duyuru.text if $HUD/Duyuru.visible else ""
	arayuz.menu = not oynaniyor and not bitti
	arayuz.bitti = bitti
	arayuz.kazandi = kazandi
	arayuz.dalga = dalga
	arayuz.saglik = saglik
	arayuz.enerji = enerji

func _saglik() -> float:
	var temizlik := 100.0 - atik
	var cesit := float(tur_sayisi) / 3.0 * 100.0
	return clampf(oksijen * 0.5 + temizlik * 0.3 + cesit * 0.2, 0.0, 100.0)

func _tavsiye() -> String:
	if not oynaniyor:
		return "Q sonar    T otonom    E enerji    plastiğe tıkla"
	if enerji < 22.0:
		return "Enerji düşük. Yosunun yanında dur veya E ile doldur"
	if oksijen < 36.0:
		return "Oksijen düşüyor. G ile yosun ek"
	if atik > 72.0:
		return "Atık karışık. Plastikleri çek, dibe bırakma"
	if otonom:
		return "Otonom açık. Enerji yosunun yanında dolar"
	return "Tıkla ve temizle, ya da drone'u kendin sür"

func _atik_soz() -> String:
	if atik > 60.0:
		return "atık karışık"
	if atik > 30.0:
		return "bulanık"
	return "berrak"

func _o2_soz() -> String:
	if oksijen < 30.0:
		return "oksijen düşük"
	if oksijen < 60.0:
		return "toparlanıyor"
	return "canlı su"
