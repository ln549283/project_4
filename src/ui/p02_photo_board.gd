class_name P02PhotoBoard
extends VBoxContainer

signal photo_pressed(index: int)

const BORDER := Color(0.62, 0.64, 0.68, 1.0)
const SELECTED := Color(1.0, 0.82, 0.42, 1.0)
const COMPARE := Color(0.48, 0.78, 0.90, 1.0)
const CARD_BG := Color(0.17, 0.18, 0.20, 1.0)

var order: Array = []
var observations: Dictionary = {}
var selected := -1
var compare_indices: Array = []

func _init() -> void:
	custom_minimum_size = Vector2(0, 600)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_theme_constant_override("separation", 18)

func configure(new_order: Array, new_observations: Dictionary, new_selected: int, new_compare: Array) -> void:
	order = new_order.duplicate()
	observations = new_observations
	selected = new_selected
	compare_indices = new_compare.duplicate()
	_rebuild()

func _ready() -> void:
	if get_child_count() == 0 and not order.is_empty():
		_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var direction := Label.new()
	direction.text = "PLUS TÔT   →   PLUS TARD"
	direction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	direction.add_theme_font_size_override("font_size", 24)
	direction.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(direction)

	var strip := HBoxContainer.new()
	strip.custom_minimum_size = Vector2(0, 480)
	strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strip.add_theme_constant_override("separation", 10)
	add_child(strip)

	for i in range(order.size()):
		var photo_id := str(order[i])
		var obs: Dictionary = observations.get(photo_id, {})
		var card := Button.new()
		card.text = _card_text(i, obs)
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.custom_minimum_size = Vector2(0, 470)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_stretch_ratio = 1.0
		card.focus_mode = Control.FOCUS_ALL
		card.add_theme_font_size_override("font_size", 22)
		card.add_theme_constant_override("outline_size", 0)
		_apply_card_style(card, i)
		card.pressed.connect(_emit_photo.bind(i))
		strip.add_child(card)

	var legend := Label.new()
	legend.text = "AU auvent · VI vitre · EN enseigne · CH cheminée · × hors cadre"
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend.add_theme_font_size_override("font_size", 18)
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(legend)

func _emit_photo(index: int) -> void:
	photo_pressed.emit(index)

func _apply_card_style(card: Button, index: int) -> void:
	var border_color := BORDER
	var border_width := 3
	if index == selected:
		border_color = SELECTED
		border_width = 7
	elif index in compare_indices:
		border_color = COMPARE
		border_width = 7

	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = CARD_BG
		style.border_color = border_color
		style.set_border_width_all(border_width)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 14
		style.content_margin_bottom = 14
		card.add_theme_stylebox_override(state, style)

func _card_text(index: int, obs: Dictionary) -> String:
	return "PHOTO %d\n\nAU  %s\n\nVI  %s\n\nEN  %s\n\nCH  %s" % [
		index + 1,
		_symbol_for("awning", obs),
		_symbol_for("pane", obs),
		_symbol_for("sign", obs),
		_symbol_for("chimney", obs),
	]

func _symbol_for(detail: String, obs: Dictionary) -> String:
	if not obs.has(detail):
		return "×"
	var state := int(obs[detail])
	match detail:
		"awning":
			return "━━" if state == 0 else "╱╲"
		"pane":
			return "□" if state == 0 else "☒"
		"sign":
			return "▭" if state == 0 else "▁"
		"chimney":
			return "▯" if state == 0 else "⌁"
	return "?"
