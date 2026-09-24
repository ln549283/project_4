class_name UiFactory
extends RefCounted

const CREAM := Color("eee4cd")
const GOLD := Color("c7a56b")
const Backdrop = preload("res://src/presentation/room_backdrop.gd")

static func _panel(fill: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(8)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

static func apply_root_theme(root: Control, font_px: int) -> void:
	var page_theme := Theme.new()
	page_theme.default_font_size = font_px
	page_theme.set_color("font_color", "Label", CREAM)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		page_theme.set_color("font_" + state + "_color", "Button", CREAM if state != "disabled" else Color("8b9590"))
	page_theme.set_stylebox("normal", "Button", _panel(Color("142b30"), Color("53605a")))
	page_theme.set_stylebox("hover", "Button", _panel(Color("213d40"), GOLD, 2))
	page_theme.set_stylebox("pressed", "Button", _panel(Color("35504e"), GOLD, 3))
	page_theme.set_stylebox("disabled", "Button", _panel(Color("172a2d"), Color("344944")))
	page_theme.set_stylebox("focus", "Button", _panel(Color(0,0,0,0), GOLD, 4))
	root.theme = page_theme

static func make_button(text: String, callable: Callable, nav: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 168 if nav else 144)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(func():
		var session := button.get_node_or_null("/root/Session") if button.is_inside_tree() else null
		if session != null and session.presentation_audio != null:
			session.presentation_audio.touch()
		callable.call()
	)
	return button

static func make_label(text: String, font_px: int = 54) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_px)
	return label

static func make_page(root: Control, title: String, objective: String = "") -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 72)
	margin.add_theme_constant_override("margin_bottom", 72)
	root.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 24)
	scroll.add_child(box)
	var heading := make_label(title, 72)
	heading.add_theme_font_override("font", preload("res://assets/slice/lantern/title.ttf"))
	if not title.is_empty(): box.add_child(heading)
	else: heading.free()
	if not objective.is_empty():
		box.add_child(make_label(objective, 54))
	# Keep the margin/scroll as child 0: controllers retain their scroll position.
	if not root is ColorRect:
		var backdrop := Backdrop.new()
		backdrop.name = "RoomBackdrop"
		backdrop.z_index = -1
		root.add_child(backdrop)
	return box
