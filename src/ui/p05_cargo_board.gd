class_name P05CargoBoard
extends VBoxContainer

signal item_pressed(item_id: String)
signal slot_pressed(index: int)

const SELECTED := Color(1.0, 0.82, 0.42, 1.0)
const BORDER := Color(0.62, 0.64, 0.68, 1.0)

var slots: Array = []
var contract: Dictionary = {}
var selected_item := ""
var compare_mode := false

func _init() -> void:
	custom_minimum_size = Vector2(0, 1000)
	add_theme_constant_override("separation", 14)

func configure(new_slots: Array, new_contract: Dictionary, new_selected: String, new_compare: bool) -> void:
	slots = new_slots.duplicate()
	contract = new_contract
	selected_item = new_selected
	compare_mode = new_compare
	_rebuild()

func _ready() -> void:
	if not contract.is_empty():
		_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	if contract.is_empty():
		return

	var title := Label.new()
	title.text = "BARGE — placer les charges pour équilibrer"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	var positions: Array = contract["positions"]
	var weights: Dictionary = contract["weights"]
	var labels: Dictionary = contract["labels"]

	var slots_box := HBoxContainer.new()
	slots_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(slots_box)
	for i in range(slots.size()):
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 220)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cargo := "VIDE"
		if slots[i] != null:
			cargo = str(labels[str(slots[i])]) + "\n" + _mass(int(weights[str(slots[i])]))
		b.text = "BERCEAU %d\nDistance pivot: %d\n\n%s" % [i + 1, abs(int(positions[i])), cargo]
		b.pressed.connect(slot_pressed.emit.bind(i))
		slots_box.add_child(b)

	var tray := Label.new()
	tray.text = "CHARGES DISPONIBLES"
	tray.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(tray)

	var items := GridContainer.new()
	items.columns = 3
	add_child(items)
	for raw in weights.keys():
		var id := str(raw)
		if id in slots:
			continue
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 120)
		b.text = "%s\n%s" % [str(labels[id]), _mass(int(weights[id]))]
		b.pressed.connect(item_pressed.emit.bind(id))
		items.add_child(b)

	var hint := Label.new()
	hint.text = "Touchez une charge puis un berceau.\n" + ("Mode comparaison actif" if compare_mode else "")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)

func _mass(value: int) -> String:
	var s := ""
	for i in range(value):
		s += "■"
	return s
