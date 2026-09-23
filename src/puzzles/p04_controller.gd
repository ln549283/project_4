extends "res://src/ui/puzzle_screen_base.gd"

const MasksRules = preload("res://src/rules/masks_rules.gd")
const P04MaskPreview = preload("res://src/ui/p04_mask_preview.gd")
var layer_visible := [true, true, true]
var compare_mode := false

func _ready() -> void:
	Session.router.current_view = "s08"
	_rebuild()

func _rebuild() -> void:
	clear_page()
	var box := setup_page("Contrejour", "Recomposer la silhouette")
	var contract: Dictionary = Session.state.puzzles_contract["p04"]
	var turns: Array = Session.state.campaign["puzzles"]["p04"]["turns"]
	for i in range(3):
		box.add_child(UiFactory.make_label("Calque %s — %s" % [["A", "B", "C"][i], "visible" if layer_visible[i] else "masqué"], Session.font_size_px(16)))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 24)
		row.add_child(UiFactory.make_button("↶", _rotate.bind(i, -1)))
		row.add_child(UiFactory.make_button("↷", _rotate.bind(i, 1)))
		row.add_child(UiFactory.make_button("Masquer / montrer", _toggle_layer.bind(i)))
		box.add_child(row)
	var masks: Array = []
	for i in range(3):
		if layer_visible[i]:
			masks.append(MasksRules.rotate_mask(contract["masks"][i], int(turns[i])))
	var union_mask := MasksRules.union_masks(masks)
	var preview := P04MaskPreview.new()
	preview.configure(union_mask, contract["target"], compare_mode)
	box.add_child(preview)
	box.add_child(UiFactory.make_button("Comparer à la cible", _toggle_compare))
	add_common_tools(
		box,
		"p04",
		_verify,
		func(): ask_reset(_reset_confirmed),
		_undo,
		"Tournez chacun des trois calques par quarts de tour. Leur union opaque doit reproduire exactement le contour observé."
	)

func _rotate(index: int, delta: int) -> void:
	history.append((Session.state.campaign["puzzles"]["p04"]["turns"] as Array).duplicate())
	Session.state.rotate_mask(index, delta)
	Session.save_now()
	feedback = ""
	_rebuild()

func _toggle_layer(index: int) -> void:
	layer_visible[index] = not bool(layer_visible[index])
	_rebuild()

func _toggle_compare() -> void:
	compare_mode = not compare_mode
	_rebuild()

func _undo() -> void:
	if history.is_empty():
		feedback = "Aucun geste à annuler."
	else:
		Session.state.campaign["puzzles"]["p04"]["turns"] = history.pop_back()
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	_rebuild()

func _reset_confirmed() -> void:
	Session.state.reset_unsolved_puzzle("p04")
	Session.save_now()
	history.clear()
	layer_visible = [true, true, true]
	compare_mode = false
	feedback = ""
	_rebuild()

func _verify() -> void:
	var result := MasksRules.validate(Session.state.campaign["puzzles"]["p04"]["turns"], Session.state.puzzles_contract["p04"])
	if result.get("valid", false):
		Session.state.resolve_puzzle("p04")
		Session.save_now()
		Session.navigate("s02", false)
	else:
		feedback = "La silhouette présente encore des manques ou des surplus."
		compare_mode = true
		_rebuild()
