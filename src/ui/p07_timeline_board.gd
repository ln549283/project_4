class_name P07TimelineBoard
extends Control

signal phase_pressed(phase: int)

const BG := Color(0.12, 0.13, 0.15, 1.0)
const COLUMN := Color(0.22, 0.23, 0.26, 1.0)
const BORDER := Color(0.60, 0.62, 0.66, 1.0)
const WATER := Color(0.28, 0.48, 0.62, 0.55)
const CARD := Color(0.48, 0.78, 0.90, 1.0)
const SELECTED := Color(1.0, 0.82, 0.42, 1.0)

var slots: Array = []
var selected_action := ""
var phase_rects: Array[Rect2] = []

func _ready() -> void:
	custom_minimum_size = Vector2(0, 500)
	mouse_filter = Control.MOUSE_FILTER_STOP

func configure(new_slots: Array, new_selected: String) -> void:
	slots = new_slots.duplicate()
	selected_action = new_selected
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
	for i in range(phase_rects.size()):
		if phase_rects[i].has_point(position):
			phase_pressed.emit(i)
			accept_event()
			return

func _draw() -> void:
	_rebuild_geometry()
	draw_rect(Rect2(Vector2.ZERO, size), BG, true)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 28), "Six phases observées — l'eau monte de 0 à 5", HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, BORDER)
	for phase in range(phase_rects.size()):
		var rect := phase_rects[phase]
		draw_rect(rect, COLUMN, true)
		draw_rect(rect, BORDER, false, 3.0, true)
		var water_height := rect.size.y * (float(phase) / 5.0) * 0.48
		if water_height > 0:
			draw_rect(Rect2(Vector2(rect.position.x, rect.end.y - water_height), Vector2(rect.size.x, water_height)), WATER, true)
		draw_string(font, rect.position + Vector2(0, 26), str(phase), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, BORDER)
		var occupant: Variant = slots[phase] if phase < slots.size() else null
		if occupant != null:
			_draw_action_card(rect.grow(-10.0), str(occupant), str(occupant) == selected_action)
		else:
			draw_rect(Rect2(rect.position + Vector2(12, 70), Vector2(rect.size.x - 24, 100)), BORDER, false, 3.0, true)
			draw_string(font, rect.position + Vector2(12, 125), "vide", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 24, 18, BORDER)

func _rebuild_geometry() -> void:
	phase_rects.clear()
	var gap := 10.0
	var margin := 6.0
	var top := 48.0
	var width := (size.x - margin * 2.0 - gap * 5.0) / 6.0
	var height := maxf(390.0, size.y - top - 18.0)
	for i in range(6):
		phase_rects.append(Rect2(Vector2(margin + float(i) * (width + gap), top), Vector2(width, height)))

func _draw_action_card(rect: Rect2, action: String, selected: bool) -> void:
	var labels := {
		"deliver": "Outils", "stairs": "Escalier", "floor": "Plancher",
		"brace": "Étais", "evacuate": "Passage", "release": "Barge",
	}
	var card := Rect2(rect.position + Vector2(0, 66), Vector2(rect.size.x, 112))
	draw_rect(card, Color(0.16, 0.18, 0.20, 1.0), true)
	draw_rect(card, SELECTED if selected else CARD, false, 4.0, true)
	draw_string(ThemeDB.fallback_font, card.position + Vector2(3, 63), str(labels.get(action, action)), HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 6, 17, CARD)
