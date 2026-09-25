extends Control
## Full-bleed scene dressing, independent of scrollable puzzle geometry.
var texture: Texture2D = preload("res://assets/slice/lantern/atelier.webp")
var shade := 0.68

func _ready() -> void:
	var session := get_node_or_null("/root/Session")
	if session != null and session.router.current_view in ["s03", "s06", "s12", "p09", "p17"]:
		texture = preload("res://assets/production/archive.webp")
	if session != null and bool(session.settings.high_contrast): shade = 0.88
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)

func _draw() -> void:
	if size.x <= 0 or size.y <= 0: return
	var ratio := maxf(size.x / texture.get_width(), size.y / texture.get_height())
	var extent := texture.get_size() * ratio
	draw_texture_rect(texture, Rect2(Vector2(0, (size.y-extent.y)*0.5), extent), false)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.025, 0.055, 0.065, shade))
