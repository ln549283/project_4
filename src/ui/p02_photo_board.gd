class_name P02PhotoBoard
extends Control

func _init() -> void:
	_apply_layout_constraints()

signal photo_pressed(index: int)

const BG := Color(0.12, 0.13, 0.15, 1.0)
const CARD := Color(0.23, 0.24, 0.27, 1.0)
const BORDER := Color(0.62, 0.64, 0.68, 1.0)
const SELECTED := Color(1.0, 0.82, 0.42, 1.0)
const COMPARE := Color(0.48, 0.78, 0.90, 1.0)
const INTACT := Color(0.76, 0.82, 0.76, 1.0)
const DAMAGED := Color(0.88, 0.58, 0.50, 1.0)
const HIDDEN := Color(0.32, 0.34, 0.38, 1.0)

var order: Array = []
var observations: Dictionary = {}
var selected := -1
var compare_indices: Array = []
var card_rects: Array[Rect2] = []

func _ready() -> void:
	_apply_layout_constraints()

func configure(new_order: Array, new_observations: Dictionary, new_selected: int, new_compare: Array) -> void:
	order = new_order.duplicate()
	observations = new_observations
	selected = new_selected
	compare_indices = new_compare.duplicate()
	_apply_layout_constraints()
	queue_redraw()

func _apply_layout_constraints() -> void:
	custom_minimum_size = Vector2(0, 600)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			_handle_tap(e.position)
			accept_event()
	elif event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if e.pressed:
			_handle_tap(e.position)
			accept_event()

func _handle_tap(position: Vector2) -> void:
	for i in range(card_rects.size()):
		if card_rects[i].has_point(position):
			photo_pressed.emit(i)
			return

func _draw() -> void:
	_rebuild_geometry()
	draw_rect(Rect2(Vector2.ZERO, size), BG, true)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 32), "PLUS TÔT", HORIZONTAL_ALIGNMENT_LEFT, 170, 22, BORDER)
	draw_string(font, Vector2(size.x - 170, 32), "PLUS TARD", HORIZONTAL_ALIGNMENT_RIGHT, 170, 22, BORDER)
	draw_line(Vector2(150, 24), Vector2(size.x - 150, 24), BORDER, 3.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(size.x - 150, 24), Vector2(size.x - 166, 14), Vector2(size.x - 166, 34)
	]), BORDER)

	for i in range(order.size()):
		var rect := card_rects[i]
		var border := SELECTED if i == selected else (COMPARE if i in compare_indices else BORDER)
		draw_rect(rect, CARD, true)
		draw_rect(rect, border, false, 6.0 if i == selected or i in compare_indices else 3.0, true)
		draw_string(font, rect.position + Vector2(0, 30), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, BORDER)
		_draw_photo(rect, observations.get(str(order[i]), {}))

func _rebuild_geometry() -> void:
	card_rects.clear()
	if order.is_empty():
		return
	var gap := 10.0
	var margin := 8.0
	var top := 58.0
	var width := (size.x - margin * 2.0 - gap * float(order.size() - 1)) / float(order.size())
	var height := maxf(470.0, size.y - top - 20.0)
	for i in range(order.size()):
		card_rects.append(Rect2(Vector2(margin + float(i) * (width + gap), top), Vector2(width, height)))

func _draw_photo(rect: Rect2, obs: Dictionary) -> void:
	var content := Rect2(rect.position + Vector2(10, 48), rect.size - Vector2(20, 62))
	var row_h := content.size.y / 4.0
	var details := ["awning", "pane", "sign", "chimney"]
	var initials := ["AU", "VI", "EN", "CH"]
	var font := ThemeDB.fallback_font
	for row in range(4):
		var cell := Rect2(Vector2(content.position.x, content.position.y + row_h * float(row)), Vector2(content.size.x, row_h - 4))
		draw_rect(cell, Color(0.17, 0.18, 0.20, 1.0), true)
		draw_string(font, cell.position + Vector2(6, 21), initials[row], HORIZONTAL_ALIGNMENT_LEFT, 34, 16, BORDER)
		var detail := details[row]
		if not obs.has(detail):
			draw_line(cell.position + Vector2(42, 18), cell.end - Vector2(8, 14), HIDDEN, 5.0, true)
			draw_line(Vector2(cell.position.x + 42, cell.end.y - 14), Vector2(cell.end.x - 8, cell.position.y + 18), HIDDEN, 5.0, true)
			continue
		_draw_detail(detail, int(obs[detail]), Rect2(cell.position + Vector2(42, 10), cell.size - Vector2(50, 20)))

func _draw_detail(detail: String, state: int, rect: Rect2) -> void:
	var color := INTACT if state == 0 else DAMAGED
	match detail:
		"awning":
			var y := rect.position.y + rect.size.y * 0.40
			if state == 0:
				draw_line(Vector2(rect.position.x + 8, y), Vector2(rect.end.x - 8, y), color, 8.0, true)
				draw_line(Vector2(rect.position.x + 16, y), Vector2(rect.position.x + 16, rect.end.y - 8), color, 4.0, true)
			else:
				var mid := rect.get_center().x
				draw_polyline(PackedVector2Array([
					Vector2(rect.position.x + 8, y), Vector2(mid - 12, y),
					Vector2(mid, y + 18), Vector2(mid + 12, y - 8), Vector2(rect.end.x - 8, y)
				]), color, 7.0, true)
		"pane":
			var pane := rect.grow(-12)
			draw_rect(pane, color, false, 6.0, true)
			if state == 1:
				draw_line(pane.position, pane.end, color, 4.0, true)
				draw_line(Vector2(pane.position.x, pane.end.y), Vector2(pane.end.x, pane.position.y), color, 4.0, true)
		"sign":
			if state == 0:
				var sign_rect := Rect2(rect.position + Vector2(18, 18), Vector2(maxf(30.0, rect.size.x - 36), maxf(24.0, rect.size.y * 0.42)))
				draw_line(Vector2(sign_rect.position.x + 10, rect.position.y + 4), Vector2(sign_rect.position.x + 10, sign_rect.position.y), color, 4.0, true)
				draw_rect(sign_rect, color, false, 5.0, true)
			else:
				var sign_rect := Rect2(Vector2(rect.position.x + 18, rect.end.y - 30), Vector2(maxf(30.0, rect.size.x - 36), 22))
				draw_rect(sign_rect, color, false, 5.0, true)
		"chimney":
			var base := Rect2(Vector2(rect.get_center().x - 18, rect.position.y + 14), Vector2(36, rect.size.y - 22))
			if state == 0:
				draw_rect(base, color, false, 6.0, true)
			else:
				draw_polyline(PackedVector2Array([
					Vector2(base.position.x, base.end.y), Vector2(base.position.x, base.position.y + 16),
					Vector2(base.get_center().x, base.position.y + 2), Vector2(base.end.x, base.position.y + 18),
					Vector2(base.end.x, base.end.y)
				]), color, 6.0, true)
