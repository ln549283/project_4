class_name P04MaskPreview
extends Control

const BG := Color(0.12, 0.13, 0.15, 1.0)
const FILLED := Color(0.16, 0.17, 0.19, 1.0)
const GRID := Color(0.42, 0.44, 0.48, 1.0)
const TARGET := Color(1.0, 0.82, 0.42, 1.0)
const EXCESS := Color(0.72, 0.38, 0.34, 1.0)

var current: Array = []
var target: Array = []
var compare := false

func _ready() -> void:
	custom_minimum_size = Vector2(0, 520)

func configure(new_current: Array, new_target: Array = [], new_compare: bool = false) -> void:
	current = new_current.duplicate()
	target = new_target.duplicate()
	compare = new_compare
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BG, true)
	if current.is_empty():
		return
	var n := current.size()
	var side := minf(size.x - 32.0, size.y - 52.0)
	var cell := floor(side / float(n))
	var grid_side := cell * float(n)
	var origin := Vector2((size.x - grid_side) * 0.5, 24.0)

	for y in range(n):
		for x in range(n):
			var rect := Rect2(origin + Vector2(float(x) * cell, float(y) * cell), Vector2(cell, cell))
			var is_current := str(current[y]).substr(x, 1) == "1"
			var is_target := compare and not target.is_empty() and str(target[y]).substr(x, 1) == "1"
			if is_current:
				draw_rect(rect.grow(-3.0), EXCESS if compare and not is_target else FILLED, true)
			if is_target:
				draw_rect(rect.grow(-5.0), TARGET, false, 5.0, true)
			draw_rect(rect, GRID, false, 1.0)

	var font := ThemeDB.fallback_font
	var label := "Ombre actuelle"
	if compare:
		label += " — contour jaune = cible"
	draw_string(font, Vector2(0, size.y - 12), label, HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, GRID)
