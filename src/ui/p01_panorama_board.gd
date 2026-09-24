class_name P01PanoramaBoard
extends Control

signal piece_pressed(index: int)

const BG := Color("112a30")
const LANDSCAPE = preload("res://assets/production/panorama.webp")
const ART_ORDER := ["L3", "L1", "L5", "L2", "L4"]
const WOOD = preload("res://assets/slice/lantern/board.webp")
const PIECE := Color(0.23, 0.24, 0.27, 1.0)
const BORDER := Color(0.60, 0.62, 0.66, 1.0)
const SELECTED := Color(1.0, 0.82, 0.42, 1.0)
const FIXED := Color(0.34, 0.36, 0.40, 1.0)

var session: Node
var previous_order: Array = []
var movement := 1.0
var order: Array = []
var contract: Dictionary = {}
var selected := -1
var piece_rects: Array[Rect2] = []

func _ready() -> void:
	session = get_node_or_null("/root/Session")
	custom_minimum_size = Vector2(0, 800)
	mouse_filter = Control.MOUSE_FILTER_STOP
	if not previous_order.is_empty() and session != null and not bool(session.settings.reduced_motion):
		movement = 0.0
		create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).tween_method(func(value: float): movement = value; queue_redraw(), 0.0, 1.0, 0.32)

func configure(new_order: Array, new_contract: Dictionary, new_selected: int) -> void:
	order = new_order.duplicate()
	contract = new_contract
	selected = new_selected
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			_handle_tap(e.position)
			accept_event()

func _handle_tap(position: Vector2) -> void:
	if movement < 1.0: return
	for i in range(piece_rects.size()):
		if piece_rects[i].has_point(position):
			if session != null and session.presentation_audio != null: session.presentation_audio.touch()
			piece_pressed.emit(i)
			return

func _draw() -> void:
	_rebuild_geometry()
	draw_texture_rect(WOOD, Rect2(Vector2.ZERO, size), false)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 32), "Touchez deux lés pour les échanger.", HORIZONTAL_ALIGNMENT_LEFT, size.x, 26, BORDER)
	if piece_rects.is_empty():
		return

	var frame := Rect2(
		Vector2(piece_rects[0].position.x - 28.0, piece_rects[0].position.y - 18.0),
		Vector2(piece_rects[-1].end.x - piece_rects[0].position.x + 56.0, piece_rects[0].size.y + 36.0)
	)
	draw_rect(frame, FIXED, false, 8.0, true)
	_draw_anchor(str(contract.get("left_anchor", "")), Vector2(frame.position.x, frame.get_center().y), 1.0, frame)
	_draw_anchor(str(contract.get("right_anchor", "")), Vector2(frame.end.x, frame.get_center().y), -1.0, frame)

	var pieces: Dictionary = contract.get("pieces", {})
	for i in range(order.size()):
		var id := str(order[i])
		var rect := piece_rects[i]
		if not previous_order.is_empty():
			var old_index := previous_order.find(id)
			if old_index >= 0: rect.position = piece_rects[old_index].position.lerp(rect.position,movement)
		if i == selected: rect.position.y -= 10
		draw_rect(Rect2(rect.position+Vector2(0,7),rect.size), Color(0,0,0,0.45))
		var source := Rect2(ART_ORDER.find(id)*LANDSCAPE.get_width()/5.0,0,LANDSCAPE.get_width()/5.0,LANDSCAPE.get_height())
		draw_texture_rect_region(LANDSCAPE,rect,source)
		draw_rect(rect, SELECTED if i == selected else BORDER, false, 6.0 if i == selected else 3.0, true)
		_draw_notch(rect)
		if pieces.has(id):
			var edges: Array = pieces[id]
			if edges.size() == 2:
				_draw_edge_signature(str(edges[0]), rect, true)
				_draw_edge_signature(str(edges[1]), rect, false)


func _rebuild_geometry() -> void:
	piece_rects.clear()
	if order.is_empty():
		return
	var gap := 10.0
	var margin_x := 36.0
	var top := 78.0
	var height := maxf(300.0, size.y - top - 34.0)
	var width := (size.x - margin_x * 2.0 - gap * float(order.size() - 1)) / float(order.size())
	for i in range(order.size()):
		piece_rects.append(Rect2(Vector2(margin_x + float(i) * (width + gap), top), Vector2(width, height)))

func _draw_notch(rect: Rect2) -> void:
	var center := Vector2(rect.get_center().x, rect.position.y)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18, 0),
		center + Vector2(0, 18),
		center + Vector2(18, 0),
	]), BG)

func _draw_anchor(edge: String, point: Vector2, inward: float, frame: Rect2) -> void:
	var features := _edge_features(edge)
	if not str(features.get("high", "")).is_empty():
		_draw_feature(str(features["high"]), Vector2(point.x, frame.position.y + frame.size.y * 0.34), inward)
	if not str(features.get("low", "")).is_empty():
		_draw_feature(str(features["low"]), Vector2(point.x, frame.position.y + frame.size.y * 0.70), inward)

func _draw_edge_signature(edge: String, rect: Rect2, left: bool) -> void:
	var x := rect.position.x if left else rect.end.x
	var inward := 1.0 if left else -1.0
	var features := _edge_features(edge)
	if not str(features.get("high", "")).is_empty():
		_draw_feature(str(features["high"]), Vector2(x, rect.position.y + rect.size.y * 0.34), inward)
	if not str(features.get("low", "")).is_empty():
		_draw_feature(str(features["low"]), Vector2(x, rect.position.y + rect.size.y * 0.70), inward)

func _edge_features(edge: String) -> Dictionary:
	if edge == "colline":
		return {"high": "colline", "low": "colline"}
	var result := {"high": "", "low": ""}
	var parts := edge.split("_")
	for i in range(parts.size()):
		if parts[i] in ["haut", "haute"] and i > 0:
			result["high"] = parts[i - 1]
		elif parts[i] == "bas" and i > 0:
			result["low"] = parts[i - 1]
	return result

func _draw_feature(token: String, origin: Vector2, inward: float) -> void:
	var code := _token_code(token)
	var color := _token_color(code)
	var p1 := origin
	var p2 := origin + Vector2(30.0 * inward, 0)
	if code % 3 == 0:
		draw_line(p1, p2, color, 6.0, true)
	elif code % 3 == 1:
		draw_dashed_line(p1, p2, color, 6.0, 10.0, true, true)
	else:
		draw_line(p1 + Vector2(0, -5), p2 + Vector2(0, -5), color, 4.0, true)
		draw_line(p1 + Vector2(0, 5), p2 + Vector2(0, 5), color, 4.0, true)
	var marker := origin + Vector2(17.0 * inward, 0)
	match code % 4:
		0:
			draw_circle(marker, 7.0, color)
		1:
			draw_rect(Rect2(marker - Vector2(7, 7), Vector2(14, 14)), color, false, 4.0, true)
		2:
			draw_colored_polygon(PackedVector2Array([marker + Vector2(0, -9), marker + Vector2(9, 8), marker + Vector2(-9, 8)]), color)
		_:
			draw_line(marker + Vector2(-7, -7), marker + Vector2(7, 7), color, 4.0, true)
			draw_line(marker + Vector2(-7, 7), marker + Vector2(7, -7), color, 4.0, true)

func _token_code(token: String) -> int:
	var tokens := ["quai", "corde", "roseau", "toit", "rail", "fenetre", "escalier", "arbre", "mur", "colline"]
	var index := tokens.find(token)
	return index if index >= 0 else 0

func _token_color(code: int) -> Color:
	var colors := [
		Color(0.80, 0.68, 0.42), Color(0.48, 0.76, 0.88), Color(0.58, 0.78, 0.54),
		Color(0.86, 0.55, 0.48), Color(0.70, 0.62, 0.86), Color(0.92, 0.78, 0.52),
		Color(0.50, 0.82, 0.72), Color(0.82, 0.62, 0.46), Color(0.68, 0.72, 0.82),
		Color(0.58, 0.78, 0.62),
	]
	return colors[clampi(code, 0, colors.size() - 1)]
