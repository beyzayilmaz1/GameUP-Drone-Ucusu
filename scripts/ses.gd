extends Node

var acik := true
var _oynatici: Dictionary = {}
var _ortam: AudioStreamPlayer

func _ready() -> void:
	for ad in ["topla", "yosun", "hata", "tur", "kazan", "kaybet", "puan"]:
		var yol := "res://ses/%s.wav" % ad
		if not ResourceLoader.exists(yol):
			continue
		var player := AudioStreamPlayer.new()
		player.stream = load(yol)
		player.volume_db = -8.0
		add_child(player)
		_oynatici[ad] = player
	if ResourceLoader.exists("res://ses/ortam.wav"):
		_ortam = AudioStreamPlayer.new()
		var akis = load("res://ses/ortam.wav").duplicate()
		if akis is AudioStreamWAV:
			akis.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_ortam.stream = akis
		_ortam.volume_db = -20.0
		add_child(_ortam)
		_ortam.play()

func cal(ad: String, perde: float = 1.0) -> void:
	if not acik or not _oynatici.has(ad):
		return
	var player: AudioStreamPlayer = _oynatici[ad]
	player.pitch_scale = perde
	player.play()

func ac_kapa() -> void:
	acik = not acik
	AudioServer.set_bus_mute(0, not acik)
