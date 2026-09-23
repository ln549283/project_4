class_name P06MapBoard
extends Control

signal node_pressed(node_id: String)

const FloodMapRules = preload("res://src/rules/flood_map_rules.gd")

const BG := Color(0.12, 0.13, 0.15, 1.0)
const EDGE := Color(0.58, 0.60, 0.64, 1.0)
const FLOODED := Color(0.28, 0.42, 0.55, 0.75)
const GAP := Color(0.46, 0.48, 0.52, 1.0)
const FRAGMENT := Color(0.72, 0.62, 0.42, 1.0)
const NODE := Color(0.24, 0.25, 0.28, 1.0)
const ACTIVE := Color(1.0, 0.82, 0.42, 1.0)
const ROUTE := Color(0.48, 0.78, 0.90, 1.0)

var state: Dictionary = {}
var contract: Dictionary = {}
var active_group := ""
var zoomed := false
var node_hit_rects: Dictionary = {}
var _scale := 1.0
var _offset := Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(0, 900)
	mouse_filter = Control.MOUSE_FILTER_STOP

func configure(new_state: Dictionary, new_contract: Dictionary, new_active_group: String, new_zoomed: bool) -> void:
	state = new_state.duplicate(true)
	contract = new_contract
	active_group = new_active_group
	zoomed = new_zoomed
	custom_minimum_size = Vector2(0, 1120 if zoomed else 900)
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
	for node_id: Variant in node_hit_rects:
		var rect: Rect2 = node_hit_rects[node_id]
		if rect.has_point(position):
			node_pressed.emit(str(node_id))
			accept_event()
			return

func _draw() -> void:
	_rebuild_geometry()
	draw_rect(Rect2(Vector2.ZERO, size), BG, true)
	if contract.is_empty():
		return
	var water := int(state.get("water_level", 0))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 30), "Plan schématique — touchez les lieux pour tracer le groupe actif", HORIZONTAL_ALIGNMENT_CENTER, size.x, 23, EDGE)
	draw_string(font, Vector2(0, 62), "Eau : repère %d" % water, HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, FLOODED)

	for raw_edge: Variant in contract.get("edges", []):
		var edge: Dictionary = raw_edge
		var flooded := water >= int(edge.get("clearance", 0))
		_draw_edge(edge, FLOODED if flooded else EDGE, 5.0, flooded)
		if bool(edge.get("stairs", false)):
			_draw_stairs(edge)

	var placements: Dictionary = state.get("fragments", {})
	for gap_id: Variant in contract.get("gaps", {}).keys():
		var gap: Dictionary = contract["gaps"][gap_id]
		var fragment_id := _fragment_at_gap(str(gap_id), placements)
		if fragment_id.is_empty():
			_draw_gap(gap)
		else:
			var fragment: Dictionary = contract["fragments"][fragment_id]
			_draw_edge({"ends": gap["ends"]}, FRAGMENT, 10.0, false)
			_draw_fragment_marker(gap, int(fragment.get("span", 0)))

	for group_id in ["school", "infirmary", "archives"]:
		var route: Array = state.get("routes", {}).get(group_id, [])
		if route.size() >= 2:
			_draw_route(group_id, route, group_id == active_group)

	for node_id: Variant in contract.get("nodes", {}).keys():
		_draw_node(str(node_id))

func _rebuild_geometry() -> void:
	node_hit_rects.clear()
	if contract.is_empty():
		return
	var canvas: Array = contract.get("canvas", [900, 1080])
	var usable := Vector2(maxf(100.0, size.x - 48.0), maxf(100.0, size.y - 120.0))
	_scale = minf(usable.x / float(canvas[0]), usable.y / float(canvas[1]))
	_offset = Vector2((size.x - float(canvas[0]) * _scale) * 0.5, 86.0 + (usable.y - float(canvas[1]) * _scale) * 0.5)
	for node_id: Variant in contract.get("nodes", {}).keys():
		var p := _node_pos(str(node_id))
		node_hit_rects[node_id] = Rect2(p - Vector2(72, 72), Vector2(144, 144))

func _node_pos(node_id: String) -> Vector2:
	var xy: Array = contract["nodes"][node_id]["xy"]
	return _offset + Vector2(float(xy[0]), float(xy[1])) * _scale

func _edge_points(edge: Dictionary) -> PackedVector2Array:
	var ends: Array = edge.get("ends", [])
	var points := PackedVector2Array()
	if ends.size() != 2:
		return points
	points.append(_node_pos(str(ends[0])))
	for raw_via: Variant in edge.get("via", []):
		var via: Array = raw_via
		points.append(_offset + Vector2(float(via[0]), float(via[1])) * _scale)
	points.append(_node_pos(str(ends[1])))
	return points

func _draw_edge(edge: Dictionary, color: Color, width: float, dashed: bool) -> void:
	var points := _edge_points(edge)
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		if dashed:
			draw_dashed_line(points[i], points[i + 1], color, width, 18.0, true, true)
		else:
			draw_line(points[i], points[i + 1], color, width, true)

func _draw_stairs(edge: Dictionary) -> void:
	var points := _edge_points(edge)
	if points.size() < 2:
		return
	var a := points[0]
	var b := points[1]
	var mid := a.lerp(b, 0.5)
	var dir := (b - a).normalized()
	var normal := Vector2(-dir.y, dir.x)
	for step in range(-2, 3):
		var center := mid + dir * float(step) * 12.0
		draw_line(center - normal * 8.0, center + normal * 8.0, Color(0.76, 0.70, 0.60), 3.0, true)

func _draw_gap(gap: Dictionary) -> void:
	var points := _edge_points({"ends": gap["ends"]})
	if points.size() < 2:
		return
	draw_dashed_line(points[0], points[1], GAP, 5.0, 20.0, true, true)
	var mid := points[0].lerp(points[1], 0.5)
	var font := ThemeDB.fallback_font
	draw_string(font, mid + Vector2(-35, -10), "%d" % int(gap.get("span", 0)), HORIZONTAL_ALIGNMENT_CENTER, 70, 20, GAP)

func _fragment_at_gap(gap_id: String, placements: Dictionary) -> String:
	for fragment_id: Variant in placements:
		if placements[fragment_id] != null and str(placements[fragment_id]) == gap_id:
			return str(fragment_id)
	return ""

func _draw_fragment_marker(gap: Dictionary, span: int) -> void:
	var points := _edge_points({"ends": gap["ends"]})
	if points.size() < 2:
		return
	var mid := points[0].lerp(points[1], 0.5)
	for i in range(span):
		draw_circle(mid + Vector2((float(i) - float(span - 1) * 0.5) * 18.0, 0), 5.0, FRAGMENT)

func _draw_node(node_id: String) -> void:
	var p := _node_pos(node_id)
	var route: Array = state.get("routes", {}).get(active_group, [])
	var active := node_id in route
	draw_circle(p, 24.0, ACTIVE if active else NODE)
	draw_circle(p, 24.0, EDGE, false, 4.0, true)
	var font := ThemeDB.fallback_font
	var label := str(contract["nodes"][node_id]["label"])
	draw_string(font, p + Vector2(-74, 55), label, HORIZONTAL_ALIGNMENT_CENTER, 148, 19, ACTIVE if active else EDGE)

func _draw_route(group_id: String, route: Array, is_active: bool) -> void:
	var edges := FloodMapRules.active_edges(state.get("fragments", {}), contract)
	var pattern := str(contract["groups"][group_id].get("pattern", "dashes"))
	var route_color := ACTIVE if is_active else Color(ROUTE.r, ROUTE.g, ROUTE.b, 0.55)
	for i in range(route.size() - 1):
		var edge := FloodMapRules.find_edge(str(route[i]), str(route[i + 1]), edges)
		if edge.is_empty():
			continue
		_draw_pattern(_edge_points(edge), pattern, route_color)

func _draw_pattern(points: PackedVector2Array, pattern: String, color: Color) -> void:
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]
		if pattern == "dots":
			var length := a.distance_to(b)
			var dir := (b - a).normalized()
			var d := 0.0
			while d <= length:
				draw_circle(a + dir * d, 5.0, color)
				d += 18.0
		elif pattern == "double":
			draw_line(a, b, color, 13.0, true)
			draw_line(a, b, BG, 5.0, true)
		else:
			draw_dashed_line(a, b, color, 9.0, 20.0, true, true)
