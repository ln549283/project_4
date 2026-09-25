class_name P07DonorBoard
extends Control

signal donor_pressed(donor_id: String)

const Art = preload("res://src/presentation/production_art.gd")
const WOOD = preload("res://assets/slice/lantern/board.webp")
const BG := Color(0.12, 0.13, 0.15, 1.0)
const CARD := Color(0.22, 0.23, 0.26, 1.0)
const BORDER := Color(0.60, 0.62, 0.66, 1.0)
const SELECTED := Color(1.0, 0.82, 0.42, 1.0)
const REFERENCE := Color(0.48, 0.78, 0.90, 1.0)

var donors: Dictionary = {}
var selected_id := ""
var donor_rects: Dictionary = {}

func _ready() -> void:
	custom_minimum_size = Vector2(0, 560)
	mouse_filter = Control.MOUSE_FILTER_STOP

func configure(new_donors: Dictionary, new_selected: String) -> void:
	donors = new_donors
	selected_id = new_selected
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
	if not pressed:
		return
	for donor_id: Variant in donor_rects:
		var rect: Rect2 = donor_rects[donor_id]
		if rect.has_point(position):
			donor_pressed.emit(str(donor_id))
			accept_event()
			return

func _draw() -> void:
	_rebuild_geometry()
	draw_texture_rect(WOOD,Rect2(Vector2.ZERO,size),false)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 28), "Référence F2 + interruption", HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, BORDER)
	_draw_reference(Rect2(Vector2(size.x * 0.18, 48), Vector2(size.x * 0.64, 150)))

	var names := {"roof": "Toiture", "door": "Porte", "floor": "Plancher"}
	for donor_id in ["roof", "door", "floor"]:
		var rect: Rect2 = donor_rects[donor_id]
		draw_rect(rect, Color("1b363b"), true)
		Art.paint(self,4,rect.grow(-24),Color(0.45,0.5,0.48))
		draw_rect(rect, SELECTED if donor_id == selected_id else BORDER, false, 5.0 if donor_id == selected_id else 3.0, true)
		draw_string(font, rect.position + Vector2(4, 28), names[donor_id], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, 20, BORDER)
		_draw_piece(rect.grow(-18.0), donors[donor_id])

func _rebuild_geometry() -> void:
	donor_rects.clear()
	var gap := 14.0
	var margin := 10.0
	var width := (size.x - margin * 2.0 - gap * 2.0) / 3.0
	for i in range(3):
		var id: String = ["roof", "door", "floor"][i]
		donor_rects[id] = Rect2(Vector2(margin + float(i) * (width + gap), 230), Vector2(width, 300))

func _draw_reference(rect: Rect2) -> void:
	var y := rect.get_center().y
	draw_line(Vector2(rect.position.x, y + 34), Vector2(rect.position.x + 70, y + 34), BORDER, 10.0, true)
	draw_line(Vector2(rect.end.x - 70, y + 34), Vector2(rect.end.x, y + 34), BORDER, 10.0, true)
	draw_line(Vector2(rect.position.x + 70, y), Vector2(rect.end.x - 70, y), REFERENCE, 10.0, true)
	draw_line(Vector2(rect.position.x + 70, y + 22), Vector2(rect.end.x - 70, y + 22), REFERENCE, 10.0, true)
	for x in [rect.position.x + 78, rect.end.x - 78]:
		draw_circle(Vector2(x, y - 10), 6.0, REFERENCE)
		draw_circle(Vector2(x, y + 32), 6.0, REFERENCE)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.end.y - 4), "3 travées · profil plat · largeur 2 · attaches appariées", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, BORDER)

func _draw_piece(rect: Rect2, donor: Dictionary) -> void:
	var center := rect.get_center()
	var left := rect.position.x + 14.0
	var right := rect.end.x - 14.0
	var width_units := int(donor.get("width", 1))
	var thickness := 12.0 + float(width_units - 1) * 16.0
	if bool(donor.get("flat", false)):
		draw_line(Vector2(left, center.y), Vector2(right, center.y), REFERENCE, thickness, true)
	else:
		draw_polyline(PackedVector2Array([
			Vector2(left, center.y + 18), Vector2(center.x, center.y - 28), Vector2(right, center.y + 18)
		]), REFERENCE, 12.0, true)
	if bool(donor.get("paired_fasteners", false)):
		for x in [left + 8, right - 8]:
			draw_circle(Vector2(x, center.y - 28), 6.0, SELECTED)
			draw_circle(Vector2(x, center.y + 28), 6.0, SELECTED)
	else:
		for x in [left + 8, right - 8]:
			draw_circle(Vector2(x, center.y + 30), 6.0, BORDER)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.end.y - 14), "portée 3", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, BORDER)
