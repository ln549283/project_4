class_name UiFactory
extends RefCounted

static func apply_root_theme(root: Control, font_px: int) -> void:
	var page_theme := Theme.new()
	page_theme.default_font_size = font_px
	root.theme = page_theme

static func make_button(text: String, callable: Callable, nav: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 168 if nav else 144)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callable)
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
	box.add_child(make_label(title, 72))
	if not objective.is_empty():
		box.add_child(make_label("Objectif — " + objective, 54))
	return box
