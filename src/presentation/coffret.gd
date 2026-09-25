extends Control
signal latch_pressed(index: int)
const BOX = preload("res://assets/production/coffret.webp")
const LATCH = preload("res://assets/production/coffret_latches.webp")
var latches: Array = [false,false]
var angles := [0.0,0.0]
var opening := false
var tweens: Array = [null,null]

func configure(values: Array) -> void:
	latches = values.duplicate()
	angles = [float(latches[0]),float(latches[1])]
	custom_minimum_size = Vector2(0,720)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

func animate_state(values: Array) -> void:
	latches = values.duplicate()
	var session := get_node_or_null("/root/Session")
	for i in range(2):
		if tweens[i] != null: tweens[i].kill()
		tweens[i] = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tweens[i].tween_method(func(v: float): angles[i] = v; queue_redraw(), float(angles[i]), float(latches[i]), 0.08 if session != null and bool(session.settings.reduced_motion) else 0.24)
	if session != null and session.presentation_audio != null:
		session.presentation_audio.play_cue("mirror_0")

func _draw() -> void:
	var scale_factor := size.x/960.0
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE*scale_factor)
	draw_texture_rect(BOX,Rect2(0,0,960,640),false)
	draw_string(preload("res://assets/slice/lantern/title.ttf"),Vector2(310,252),"Orme-sur-Rive",HORIZONTAL_ALIGNMENT_CENTER,334,34,Color("463c2d"))
	for i in range(2):
		var x := 215.0 if i == 0 else 741.0
		draw_set_transform(Vector2(x,452)*scale_factor,0,Vector2(scale_factor,scale_factor*lerpf(1.0,-0.65,float(angles[i]))))
		draw_texture_rect_region(LATCH,Rect2(-19,0,38,48),Rect2(316 if i==0 else 1155,722,60,78))
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE*scale_factor)
		draw_string(ThemeDB.fallback_font,Vector2(x-110,642),"Soulevée" if latches[i] else "Soulever",HORIZONTAL_ALIGNMENT_CENTER,220,38,Color("eadfc8"))

func reveal() -> void:
	opening = true
	var session := get_node_or_null("/root/Session")
	var duration := 0.08 if session != null and bool(session.settings.reduced_motion) else 0.45
	if session != null and session.presentation_audio != null: session.presentation_audio.play_cue("mark")
	await create_tween().tween_property(self,"modulate:a",0.0,duration).finished

func _gui_input(event: InputEvent) -> void:
	if opening: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = event.position * 960.0 / size.x
		for i in range(2):
			var x := 215.0 if i == 0 else 741.0
			if Rect2(x-80,400,160,260).has_point(p):
				latch_pressed.emit(i)
				accept_event()
				return
