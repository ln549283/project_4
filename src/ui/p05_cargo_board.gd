class_name P05CargoBoard
extends Control

signal item_pressed(item_id: String)
signal slot_pressed(index: int)

const BG := Color(0.12, 0.13, 0.15, 1.0)
const BEAM := Color(0.60, 0.62, 0.66, 1.0)
const SLOT := Color(0.24, 0.25, 0.28, 1.0)
const SELECTED := Color(1.0, 0.82, 0.42, 1.0)
const MASS := Color(0.48, 0.78, 0.90, 1.0)
const ARCH := Color(0.48, 0.50, 0.54, 1.0)

var slots: Array = []
var contract: Dictionary = {}
var selected_item := ""
var compare_mode := false
var slot_rects: Array[Rect2] = []
var item_rects: Dictionary = {}

func _ready() -> void:
	custom_minimum_size = Vector2(0, 720)
	mouse_filter = Control.MOUSE_FILTER_STOP

func configure(new_slots: Array, new_contract: Dictionary, new_selected: String, new_compare: bool) -> void:
	slots = new_slots.duplicate()
	contract = new_contract
	selected_item = new_selected
	compare_mode = new_compare
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	var position := Vector2.ZERO
	var pressed := false
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		position = e.position
		pressed = e.button_index == MOUSE_BUTTON_LEFT and e.pressed
	elif event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		position = e.position
		pressed = e.pressed
	if not pressed:
		return
	for item_id: Variant in item_rects:
		var rect: Rect2 = item_rects[item_id]
		if rect.has_point(position):
			item_pressed.emit(str(item_id))
			accept_event()
			return
	for i in range(slot_rects.size()):
		if slot_rects[i].has_point(position):
			slot_pressed.emit(i)
			accept_event()
			return

func _draw() -> void:
	_rebuild_geometry()
	draw_rect(Rect2(Vector2.ZERO, size), BG, true)
	if contract.is_empty():
		return
	var positions: Array = contract["positions"]
	var weights: Dictionary = contract["weights"]
	var labels: Dictionary = contract["labels"]
	var moment := 0
	for i in range(min(slots.size(), positions.size())):
		if slots[i] != null:
			moment += int(positions[i]) * int(weights[str(slots[i])])

	var angle_deg := clampf(float(moment) * 0.35, -8.0, 8.0)
	var slope := tan(deg_to_rad(angle_deg))
	var center := Vector2(size.x * 0.5, 270.0)
	var spacing := minf(118.0, (size.x - 170.0) / 6.0)
	var left_x := center.x - 3.35 * spacing
	var right_x := center.x + 3.35 * spacing
	var left_y := center.y + slope * (left_x - center.x)
	var right_y := center.y + slope * (right_x - center.x)
	draw_line(Vector2(left_x, left_y), Vector2(right_x, right_y), BEAM, 16.0, true)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-34, 42), center + Vector2(34, 42), center + Vector2(0, 2)
	]), ARCH)

	_draw_gauge(center, angle_deg)

	for i in range(slot_rects.size()):
		var rect := slot_rects[i]
		var x := rect.get_center().x
		var y := center.y + slope * (x - center.x)
		rect.position.y = y - rect.size.y * 0.5
		slot_rects[i] = rect
		var pos := int(positions[i])
		draw_rect(rect, SLOT, true)
		draw_rect(rect, SELECTED if slots[i] != null and str(slots[i]) == selected_item else BEAM, false, 4.0, true)
		if abs(pos) > 1:
			_draw_arch(rect)
		if compare_mode:
			draw_line(center + Vector2(0, 58), Vector2(rect.get_center().x, rect.end.y + 16), Color(BEAM.r, BEAM.g, BEAM.b, 0.55), 2.0, true)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(rect.position.x, rect.end.y + 26), "%+d" % pos, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 20, BEAM)
		if slots[i] != null:
			var item := str(slots[i])
			_draw_item(rect.grow(-8.0), str(labels[item]), int(weights[item]), item == selected_item)

	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 430), "Plateau — touchez une charge puis un berceau", HORIZONTAL_ALIGNMENT_CENTER, size.x, 24, BEAM)
	for item_id: Variant in item_rects:
		var rect: Rect2 = item_rects[item_id]
		_draw_item(rect, str(labels[str(item_id)]), int(weights[str(item_id)]), str(item_id) == selected_item)

func _rebuild_geometry() -> void:
	slot_rects.clear()
	item_rects.clear()
	if contract.is_empty():
		return
	var positions: Array = contract["positions"]
	var center_x := size.x * 0.5
	var spacing := minf(118.0, (size.x - 170.0) / 6.0)
	for raw_pos: Variant in positions:
		var pos := int(raw_pos)
		var x := center_x + float(pos) * spacing
		slot_rects.append(Rect2(Vector2(x - 54, 210), Vector2(108, 116)))

	var available: Array[String] = []
	for raw_item: Variant in contract["weights"].keys():
		var item := str(raw_item)
		if item not in slots:
			available.append(item)
	available.sort()
	var cols := 3
	var gap := 12.0
	var card_w := (size.x - 32.0 - gap * 2.0) / 3.0
	var card_h := 112.0
	for i in range(available.size()):
		var row := int(i / cols)
		var col := i % cols
		item_rects[available[i]] = Rect2(Vector2(16 + float(col) * (card_w + gap), 458 + float(row) * (card_h + gap)), Vector2(card_w, card_h))

func _draw_gauge(center: Vector2, angle_deg: float) -> void:
	var origin := Vector2(center.x, 88)
	draw_line(origin + Vector2(-80, 0), origin + Vector2(80, 0), BEAM, 3.0, true)
	draw_line(origin + Vector2(0, -12), origin + Vector2(0, 12), SELECTED, 4.0, true)
	var tip := origin + Vector2(sin(deg_to_rad(angle_deg)) * 62.0, -cos(deg_to_rad(angle_deg)) * 62.0)
	draw_line(origin, tip, SELECTED, 7.0, true)
	draw_circle(origin, 8.0, SELECTED)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(origin.x - 100, 130), "équilibre", HORIZONTAL_ALIGNMENT_CENTER, 200, 20, BEAM)

func _draw_arch(rect: Rect2) -> void:
	var top := rect.position.y - 28.0
	draw_line(Vector2(rect.position.x + 10, rect.position.y), Vector2(rect.position.x + 10, top), ARCH, 5.0, true)
	draw_line(Vector2(rect.end.x - 10, rect.position.y), Vector2(rect.end.x - 10, top), ARCH, 5.0, true)
	draw_line(Vector2(rect.position.x + 10, top), Vector2(rect.end.x - 10, top), ARCH, 5.0, true)

func _draw_item(rect: Rect2, label: String, weight: int, selected: bool) -> void:
	draw_rect(rect, Color(0.18, 0.19, 0.21, 1.0), true)
	draw_rect(rect, SELECTED if selected else BEAM, false, 4.0, true)
	var font := ThemeDB.fallback_font
	draw_string(font, rect.position + Vector2(6, 28), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, 18, BEAM)
	var dot_gap := 15.0
	var total := float(weight - 1) * dot_gap
	var start_x := rect.get_center().x - total * 0.5
	for i in range(weight):
		draw_circle(Vector2(start_x + float(i) * dot_gap, rect.end.y - 24), 5.0, MASS)
