class_name P04MaskPreview
extends VBoxContainer

const EMPTY_BG := Color("e7d6b0")
const FILLED_BG := Color("17343b")
const GRID_BORDER := Color("bfaa81")
const TARGET_BORDER := Color("bb793e")
const EXCESS_BG := Color(0.72, 0.38, 0.34, 1.0)
const MUTED := Color(0.68, 0.70, 0.73, 1.0)

var current: Array = []
var target: Array = []
var compare := false

func _init() -> void:
	custom_minimum_size = Vector2(0, 850)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_theme_constant_override("separation", 16)

func configure(new_current: Array, new_target: Array = [], new_compare: bool = false) -> void:
	current = new_current.duplicate()
	target = new_target.duplicate()
	compare = new_compare
	_rebuild()

func _ready() -> void:
	if get_child_count() == 0 and not current.is_empty():
		_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var title := Label.new()
	title.text = "OMBRE ACTUELLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", MUTED)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)

	if current.is_empty():
		return

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var grid := GridContainer.new()
	grid.columns = current.size()
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 0)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(grid)

	for y in range(current.size()):
		for x in range(str(current[y]).length()):
			grid.add_child(_make_cell(y, x))

	var legend := Label.new()
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend.add_theme_font_size_override("font_size", 38)
	legend.add_theme_color_override("font_color", MUTED)
	legend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if compare:
		legend.text = "Contour cuivre = silhouette cible · rouge = ombre en trop"
	else:
		legend.text = "Superposition des trois calques visibles"
	add_child(legend)

func _make_cell(y: int, x: int) -> PanelContainer:
	var cell := PanelContainer.new()
	cell.custom_minimum_size = Vector2(112, 112)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var is_current := str(current[y]).substr(x, 1) == "1"
	var is_target := compare and not target.is_empty() and str(target[y]).substr(x, 1) == "1"

	var style := StyleBoxFlat.new()
	style.bg_color = FILLED_BG if is_current else EMPTY_BG
	style.border_color = GRID_BORDER
	style.set_border_width_all(0)

	if compare:
		if is_target:
			style.border_color = TARGET_BORDER
			style.set_border_width_all(7)
		if is_current and not is_target:
			style.bg_color = EXCESS_BG

	cell.add_theme_stylebox_override("panel", style)
	return cell
