extends "res://src/slice/lantern_audio.gd"
## A persistent bed across pages; P13 owns its own validated audio scene.
var slice_active := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not slice_active: start()

func set_slice_active(active: bool) -> void:
	slice_active = active
	if music == null: return
	music.stream_paused = active
	ambience.stream_paused = active

func touch() -> void:
	if slice_active: return
	start()
	apply_levels()
	play_cue("touch")

func _notification(what: int) -> void:
	super._notification(what)
	if what == NOTIFICATION_APPLICATION_RESUMED and slice_active:
		set_slice_active(true)

func apply_levels() -> void:
	super.apply_levels()
	if music == null: return
	if float(Session.settings.music) <= 0.0: music.volume_db = -80.0
	if float(Session.settings.sfx) <= 0.0:
		ambience.volume_db = -80.0
		for player in effects: player.volume_db = -80.0
