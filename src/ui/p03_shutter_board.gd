class_name P03ShutterBoard
extends Control

signal shutter_pressed(index: int)
signal route_pressed(route_id: String)

const RoutesRules = preload("res://src/rules/routes_rules.gd")

const FACE_BG := Color(0.16, 0.17, 0.19, 1.0)
const FACE_BORDER := Color(0.62, 0.64, 0.67, 1.0)
const CHANNEL_COLOR := Color(0.72, 0.74, 0.77, 1.0)
const PORT_COLOR := Color(0.92, 0.93, 0.94, 1.0)
const MUTED_TEXT := Color(0.68, 0.70, 0.73, 1.0)
const ACTIVE_COLOR := Color(1.0, 0.82, 0.42, 1.0)
const CHIP_BG := Color(0.11, 0.12, 0.14, 1.0)

var bits: Array = []
var contract: Dictionary = {}
var tile_pairs: Dictionary = {}
var traced_route := ""

var tile_rects: Array[Rect2] = []
var route_hit_rects: Dictionary = {}
var _board_rect := Rect2()
var _cell_size := 0.0
var _gap := 18.0

func _ready() -> void:
	custom_minimum_size = Vector2(0, 880)
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_unhandled_input(false)

func configure(new_bits: Array, new_contract: Dictionary, new_tile_pairs: Dictionary, new_traced_route: String) -> void:
	bits = new_bits.duplicate()
	contract = new_contract
	tile_pairs = new_tile_pairs
	traced_route = new_traced_route
	custom_minimum_size = Vector2(0, 880)
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if contract.is_empty():
		return
	_rebuild_geometry()
	_draw_instruction()
	_draw_external_ports()
	for index in range(tile_rects.size()):
		_draw_shutter(index, tile_rects[index])
	if not traced_route.is_empty():
		_draw_traced_route(traced_route)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_handle_tap(mouse_event.position)
			accept_event()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_handle_tap(touch_event.position)
			accept_event()

func _handle_tap(position: Vector2) -> void:
	for route_id: Variant in route_hit_rects:
		var rect: Rect2 = route_hit_rects[route_id]
		if rect.has_point(position):
			route_pressed.emit(str(route_id))
			return
	for index in range(tile_rects.size()):
		if tile_rects[index].has_point(position):
			shutter_pressed.emit(index)
			return

func _rebuild_geometry() -> void:
	tile_rects.clear()
	route_hit_rects.clear()

	var rows := int(contract.get("rows", 2))
	var cols := int(contract.get("cols", 3))
	var right_margin := clampf(size.x * 0.24, 190.0, 250.0)
	var left_margin := 18.0
	var top_margin := 160.0
	var bottom_margin := 190.0
	var usable_width := maxf(450.0, size.x - left_margin - right_margin)
	var width_cell := (usable_width - _gap * float(cols - 1)) / float(cols)
	var height_cell := (size.y - top_margin - bottom_margin - _gap * float(rows - 1)) / float(rows)
	_cell_size = floor(minf(width_cell, height_cell))
	_cell_size = maxf(_cell_size, 150.0)

	var board_width := _cell_size * float(cols) + _gap * float(cols - 1)
	var board_height := _cell_size * float(rows) + _gap * float(rows - 1)
	_board_rect = Rect2(Vector2(left_margin, top_margin), Vector2(board_width, board_height))

	for r in range(rows):
		for c in range(cols):
			var pos := Vector2(
				_board_rect.position.x + float(c) * (_cell_size + _gap),
				_board_rect.position.y + float(r) * (_cell_size + _gap)
			)
			tile_rects.append(Rect2(pos, Vector2(_cell_size, _cell_size)))

	for raw_route: Variant in contract.get("routes", []):
		var route: Dictionary = raw_route
		var route_id := str(route.get("id", ""))
		var start: Array = route.get("start", [])
		if start.size() != 3:
			continue
		route_hit_rects[route_id] = _route_chip_rect(start, true)

func _draw_instruction() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 38), "Touchez un volet pour le retourner.", HORIZONTAL_ALIGNMENT_LEFT, size.x, 30, PORT_COLOR)
	draw_string(font, Vector2(0, 78), "Touchez un départ pour suivre son trajet actuel.", HORIZONTAL_ALIGNMENT_LEFT, size.x, 26, MUTED_TEXT)

func _draw_shutter(index: int, rect: Rect2) -> void:
	if index >= bits.size():
		return
	var bit := int(bits[index])
	draw_rect(rect, FACE_BG, true)
	draw_rect(rect, FACE_BORDER, false, 4.0, true)

	var tab := Rect2(
		Vector2(rect.get_center().x - 34.0, rect.end.y - 16.0),
		Vector2(68.0, 28.0)
	)
	draw_rect(tab, FACE_BORDER, true)
	draw_rect(tab, Color(0.08, 0.09, 0.10, 1.0), false, 3.0, true)

	var ports := _ports_for_rect(rect)
	for side: Variant in ports:
		draw_circle(ports[side], 8.0, PORT_COLOR)

	var raw_pairs: Array = tile_pairs.get(str(bit), tile_pairs.get(bit, []))
	for raw_pair: Variant in raw_pairs:
		var pair: Array = raw_pair
		if pair.size() == 2:
			_draw_channel(rect, str(pair[0]), str(pair[1]), CHANNEL_COLOR, 8.0)

	var font := ThemeDB.fallback_font
	draw_string(font, rect.position + Vector2(14, 32), "A" if bit == 0 else "B", HORIZONTAL_ALIGNMENT_LEFT, 40, 25, PORT_COLOR)
	draw_string(font, rect.position + Vector2(rect.size.x - 48, 32), str(index + 1), HORIZONTAL_ALIGNMENT_CENTER, 34, 23, MUTED_TEXT)

func _draw_external_ports() -> void:
	for raw_route: Variant in contract.get("routes", []):
		var route: Dictionary = raw_route
		var route_id := str(route.get("id", ""))
		var selected := route_id == traced_route
		_draw_route_marker(route["start"], str(route["start_label"]), true, selected, route_id)
		_draw_route_marker(route["end"], str(route["end_label"]), false, selected, route_id)

func _draw_route_marker(endpoint: Array, label: String, is_start: bool, selected: bool, route_id: String) -> void:
	if endpoint.size() != 3:
		return
	var port := _endpoint_position(endpoint)
	var outward := _outward_vector(str(endpoint[2]))
	var stem_end := port + outward * 28.0
	draw_line(port, stem_end, ACTIVE_COLOR if selected else FACE_BORDER, 5.0, true)

	var chip := _route_chip_rect(endpoint, is_start)
	if is_start:
		draw_rect(chip, CHIP_BG, true)
		draw_rect(chip, ACTIVE_COLOR if selected else FACE_BORDER, false, 4.0, true)
		var font := ThemeDB.fallback_font
		draw_string(font, chip.position + Vector2(10, 34), "DÉPART", HORIZONTAL_ALIGNMENT_CENTER, chip.size.x - 20.0, 20, MUTED_TEXT)
		draw_string(font, chip.position + Vector2(10, 77), label, HORIZONTAL_ALIGNMENT_CENTER, chip.size.x - 20.0, 27, PORT_COLOR)
		if selected:
			draw_string(font, chip.position + Vector2(10, 111), "TRACÉ", HORIZONTAL_ALIGNMENT_CENTER, chip.size.x - 20.0, 18, ACTIVE_COLOR)
	else:
		var font := ThemeDB.fallback_font
		draw_string(font, chip.position + Vector2(8, 28), "ARRIVÉE", HORIZONTAL_ALIGNMENT_CENTER, chip.size.x - 16.0, 18, MUTED_TEXT)
		draw_string(font, chip.position + Vector2(8, 61), label, HORIZONTAL_ALIGNMENT_CENTER, chip.size.x - 16.0, 24, PORT_COLOR)

func _draw_traced_route(route_id: String) -> void:
	var route: Dictionary = {}
	for raw_route: Variant in contract.get("routes", []):
		var candidate: Dictionary = raw_route
		if str(candidate.get("id", "")) == route_id:
			route = candidate
			break
	if route.is_empty():
		return

	var rows := int(contract.get("rows", 2))
	var cols := int(contract.get("cols", 3))
	var traced: Dictionary = RoutesRules.trace(bits, rows, cols, route["start"], tile_pairs)
	var visited: Array = traced.get("visited", [])
	var pattern := str(route.get("pattern", "dashes"))

	var start_pos := _endpoint_position(route["start"])
	_draw_route_segment(PackedVector2Array([start_pos + _outward_vector(str(route["start"][2])) * 30.0, start_pos]), pattern)

	for raw_visit: Variant in visited:
		var visit: Array = raw_visit
		if visit.size() != 3:
			continue
		var r := int(visit[0])
		var c := int(visit[1])
		var entry := str(visit[2])
		var index := r * cols + c
		if index < 0 or index >= tile_rects.size() or index >= bits.size():
			continue
		var bit := int(bits[index])
		var pair_map := _pair_map(tile_pairs.get(str(bit), tile_pairs.get(bit, [])))
		if not pair_map.has(entry):
			continue
		var out_side := str(pair_map[entry])
		var points := _channel_points(tile_rects[index], entry, out_side)
		_draw_route_segment(points, pattern)

	var endpoint: Array = traced.get("end", [])
	if endpoint.size() == 3:
		var end_pos := _endpoint_position(endpoint)
		_draw_route_segment(PackedVector2Array([end_pos, end_pos + _outward_vector(str(endpoint[2])) * 30.0]), pattern)

func _draw_route_segment(points: PackedVector2Array, pattern: String) -> void:
	if points.size() < 2:
		return
	if pattern == "dots":
		for i in range(points.size() - 1):
			_draw_dots_between(points[i], points[i + 1])
	elif pattern == "double":
		draw_polyline(points, ACTIVE_COLOR, 15.0, true)
		draw_polyline(points, FACE_BG, 6.0, true)
	else:
		for i in range(points.size() - 1):
			draw_dashed_line(points[i], points[i + 1], ACTIVE_COLOR, 10.0, 22.0, true, true)

func _draw_dots_between(a: Vector2, b: Vector2) -> void:
	var length := a.distance_to(b)
	if length <= 0.0:
		return
	var direction := (b - a) / length
	var offset := 0.0
	while offset <= length:
		draw_circle(a + direction * offset, 5.0, ACTIVE_COLOR)
		offset += 18.0

func _draw_channel(rect: Rect2, a: String, b: String, color: Color, width: float) -> void:
	draw_polyline(_channel_points(rect, a, b), color, width, true)

func _channel_points(rect: Rect2, a: String, b: String) -> PackedVector2Array:
	var ports := _ports_for_rect(rect)
	var p0: Vector2 = ports[a]
	var p2: Vector2 = ports[b]
	var corner := _control_corner(rect, a, b)
	var points := PackedVector2Array()
	for step in range(13):
		var t := float(step) / 12.0
		var inv := 1.0 - t
		points.append(inv * inv * p0 + 2.0 * inv * t * corner + t * t * p2)
	return points

func _ports_for_rect(rect: Rect2) -> Dictionary:
	return {
		"N": Vector2(rect.get_center().x, rect.position.y),
		"E": Vector2(rect.end.x, rect.get_center().y),
		"S": Vector2(rect.get_center().x, rect.end.y),
		"W": Vector2(rect.position.x, rect.get_center().y),
	}

func _control_corner(rect: Rect2, a: String, b: String) -> Vector2:
	var pair := [a, b]
	if "N" in pair and "E" in pair:
		return Vector2(rect.end.x - rect.size.x * 0.20, rect.position.y + rect.size.y * 0.20)
	if "N" in pair and "W" in pair:
		return Vector2(rect.position.x + rect.size.x * 0.20, rect.position.y + rect.size.y * 0.20)
	if "S" in pair and "E" in pair:
		return Vector2(rect.end.x - rect.size.x * 0.20, rect.end.y - rect.size.y * 0.20)
	return Vector2(rect.position.x + rect.size.x * 0.20, rect.end.y - rect.size.y * 0.20)

func _endpoint_position(endpoint: Array) -> Vector2:
	if endpoint.size() != 3:
		return Vector2.ZERO
	var cols := int(contract.get("cols", 3))
	var r := int(endpoint[0])
	var c := int(endpoint[1])
	var index := r * cols + c
	if index < 0 or index >= tile_rects.size():
		return Vector2.ZERO
	return _ports_for_rect(tile_rects[index])[str(endpoint[2])]

func _route_chip_rect(endpoint: Array, is_start: bool) -> Rect2:
	if endpoint.size() != 3:
		return Rect2()
	var port := _endpoint_position(endpoint)
	var side := str(endpoint[2])
	var width := 190.0
	var height := 144.0 if is_start else 82.0
	if side == "N":
		return Rect2(Vector2(port.x - width * 0.5, _board_rect.position.y - height - 18.0), Vector2(width, height))
	if side == "S":
		return Rect2(Vector2(port.x - width * 0.5, _board_rect.end.y + 18.0), Vector2(width, height))
	if side == "E":
		return Rect2(Vector2(_board_rect.end.x + 26.0, port.y - height * 0.5), Vector2(maxf(160.0, size.x - _board_rect.end.x - 36.0), height))
	return Rect2(Vector2(0.0, port.y - height * 0.5), Vector2(maxf(150.0, _board_rect.position.x - 16.0), height))

func _outward_vector(side: String) -> Vector2:
	match side:
		"N":
			return Vector2.UP
		"E":
			return Vector2.RIGHT
		"S":
			return Vector2.DOWN
		"W":
			return Vector2.LEFT
	return Vector2.ZERO

func _pair_map(raw_pairs: Array) -> Dictionary:
	var result: Dictionary = {}
	for raw_pair: Variant in raw_pairs:
		var pair: Array = raw_pair
		if pair.size() == 2:
			result[str(pair[0])] = str(pair[1])
			result[str(pair[1])] = str(pair[0])
	return result
