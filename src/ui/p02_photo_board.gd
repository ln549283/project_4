class_name P02PhotoBoard
extends VBoxContainer

signal photo_pressed(index: int)

const BORDER := Color(0.62, 0.64, 0.68, 1.0)
const SELECTED := Color(1.0, 0.82, 0.42, 1.0)
const COMPARE := Color(0.48, 0.78, 0.90, 1.0)
const CARD_BG := Color(0.17, 0.18, 0.20, 1.0)
const TEXT := Color(0.90, 0.91, 0.93, 1.0)
const MUTED := Color(0.68, 0.70, 0.73, 1.0)

const DETAIL_ORDER := ["awning", "pane", "sign", "chimney"]
const DETAIL_LABELS := {
	"awning": "Auvent",
	"pane": "Vitre",
	"sign": "Enseigne",
	"chimney": "Cheminée",
}
const STATE_LABELS := {
	"awning": ["intact", "déchiré"],
	"pane": ["intacte", "brisée"],
	"sign": ["fixée", "tombée"],
	"chimney": ["entière", "ébréchée"],
}

var order: Array = []
var observations: Dictionary = {}
var selected := -1
var compare_indices: Array = []

func _init() -> void:
	custom_minimum_size = Vector2(0, 1280)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_theme_constant_override("separation", 14)

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

	var earlier := Label.new()
	earlier.text = "PLUS TÔT"
	earlier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	earlier.add_theme_font_size_override("font_size", 24)
	earlier.add_theme_color_override("font_color", MUTED)
	earlier.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(earlier)

	for i in range(order.size()):
		add_child(_make_photo_card(i, str(order[i]), observations.get(str(order[i]), {})))
		if i < order.size() - 1:
			var arrow := Label.new()
			arrow.text = "↓"
			arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			arrow.add_theme_font_size_override("font_size", 28)
			arrow.add_theme_color_override("font_color", MUTED)
			arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(arrow)

	var later := Label.new()
	later.text = "PLUS TARD"
	later.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	later.add_theme_font_size_override("font_size", 24)
	later.add_theme_color_override("font_color", MUTED)
	later.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(later)

func _make_photo_card(index: int, photo_id: String, obs: Dictionary) -> Button:
	var card := Button.new()
	card.custom_minimum_size = Vector2(0, 208)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.focus_mode = Control.FOCUS_ALL
	card.pressed.connect(_emit_photo.bind(index))
	_apply_card_style(card, index)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.offset_left = 12
	margin.offset_top = 10
	margin.offset_right = -12
	margin.offset_bottom = -10
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(body)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(header)

	var number := Label.new()
	number.text = "PHOTO %d" % (index + 1)
	number.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	number.add_theme_font_size_override("font_size", 24)
	number.add_theme_color_override("font_color", TEXT)
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(number)

	var source := Label.new()
	source.text = photo_id
	source.add_theme_font_size_override("font_size", 18)
	source.add_theme_color_override("font_color", MUTED)
	source.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(source)

	var details := HBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 8)
	details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(details)

	for detail in DETAIL_ORDER:
		details.add_child(_make_detail_cell(detail, obs))

	return card

func _make_detail_cell(detail: String, obs: Dictionary) -> VBoxContainer:
	var cell := VBoxContainer.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.size_flags_stretch_ratio = 1.0
	cell.add_theme_constant_override("separation", 4)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(72, 72)
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(_icon_path(detail, obs)) as Texture2D
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(icon)

	var label := Label.new()
	label.text = str(DETAIL_LABELS[detail])
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", MUTED)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(label)

	var state := Label.new()
	state.text = _state_label(detail, obs)
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state.add_theme_font_size_override("font_size", 15)
	state.add_theme_color_override("font_color", TEXT)
	state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(state)

	return cell

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
		card.add_theme_stylebox_override(state, style)

func _icon_path(detail: String, obs: Dictionary) -> String:
	if not obs.has(detail):
		return "res://assets/greybox/p02/missing.svg"
	return "res://assets/greybox/p02/%s_%d.svg" % [detail, int(obs[detail])]

func _state_label(detail: String, obs: Dictionary) -> String:
	if not obs.has(detail):
		return "hors cadre"
	return str(STATE_LABELS[detail][int(obs[detail])])
