extends "res://src/ui/puzzle_screen_base.gd"

const ChronologyRules = preload("res://src/rules/chronology_rules.gd")

const DETAIL_NAMES := {"awning": "Auvent", "pane": "Vitre", "sign": "Enseigne", "chimney": "Cheminée"}
const STATE_NAMES := {
	"awning": ["intact", "déchiré"],
	"pane": ["intacte", "brisée"],
	"sign": ["fixée", "tombée"],
	"chimney": ["entière", "ébréchée"],
}

var selected := -1
var compare_mode := false
var compare_indices: Array[int] = []

func _ready() -> void:
	Session.router.current_view = "s06"
	_rebuild()

func _rebuild() -> void:
	clear_page()
	var box := setup_page("Photographies", "Retrouver l'ordre des photographies")
	box.add_child(UiFactory.make_label("Même crue, même montée des eaux. Aucune réparation entre ces cinq prises.", Session.font_size_px(18)))
	if compare_mode:
		box.add_child(UiFactory.make_label("Mode comparaison : choisissez jusqu'à deux photographies.", Session.font_size_px(16)))
	var order: Array = Session.state.campaign["puzzles"]["p02"]["order"]
	for i in range(order.size()):
		var id := str(order[i])
		var label := "%d. %s" % [i + 1, _photo_summary(id)]
		if i == selected:
			label = "[Sélectionnée] " + label
		if i in compare_indices:
			label = "[Comparer] " + label
		box.add_child(UiFactory.make_button(label, _select.bind(i)))
	if compare_indices.size() == 2:
		box.add_child(UiFactory.make_label("Comparaison\n• %s\n• %s" % [_photo_summary(str(order[compare_indices[0]])), _photo_summary(str(order[compare_indices[1]]))], Session.font_size_px(16)))
	box.add_child(UiFactory.make_button("Comparer", _toggle_compare))
	box.add_child(UiFactory.make_button("Agrandir la sélection", _zoom_selected))
	add_common_tools(
		box,
		"p02",
		_verify,
		func(): ask_reset(_reset_confirmed),
		_undo,
		"Classez les cinq prises de plus tôt vers plus tard. Un élément endommagé ne redevient pas intact pendant cette série."
	)

func _photo_summary(photo_id: String) -> String:
	var observations: Dictionary = Session.state.puzzles_contract["p02"]["observations"][photo_id]
	var parts: Array[String] = []
	for detail in ["awning", "pane", "sign", "chimney"]:
		if observations.has(detail):
			parts.append("%s %s" % [DETAIL_NAMES[detail], STATE_NAMES[detail][int(observations[detail])]])
		else:
			parts.append("%s hors cadre" % DETAIL_NAMES[detail])
	return " · ".join(parts)

func _select(index: int) -> void:
	if compare_mode:
		if index in compare_indices:
			compare_indices.erase(index)
		elif compare_indices.size() < 2:
			compare_indices.append(index)
		_rebuild()
		return
	if selected < 0:
		selected = index
	elif selected == index:
		selected = -1
	else:
		history.append((Session.state.campaign["puzzles"]["p02"]["order"] as Array).duplicate())
		Session.state.swap_order("p02", selected, index)
		Session.save_now()
		selected = -1
	_rebuild()

func _toggle_compare() -> void:
	compare_mode = not compare_mode
	selected = -1
	if not compare_mode:
		compare_indices.clear()
	_rebuild()

func _zoom_selected() -> void:
	if selected < 0 and compare_indices.is_empty():
		feedback = "Sélectionnez d'abord une photographie."
		_rebuild()
		return
	var index := selected if selected >= 0 else compare_indices[0]
	var order: Array = Session.state.campaign["puzzles"]["p02"]["order"]
	var overlay := preload("res://scenes/ui/image_detail.tscn").instantiate()
	overlay.configure("Photographie agrandie", _photo_summary(str(order[index])))
	add_child(overlay)

func _undo() -> void:
	if history.is_empty():
		feedback = "Aucun geste à annuler."
	else:
		Session.state.campaign["puzzles"]["p02"]["order"] = history.pop_back()
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	selected = -1
	compare_indices.clear()
	_rebuild()

func _reset_confirmed() -> void:
	Session.state.reset_unsolved_puzzle("p02")
	Session.save_now()
	history.clear()
	selected = -1
	compare_indices.clear()
	feedback = ""
	_rebuild()

func _verify() -> void:
	var state: Array = Session.state.campaign["puzzles"]["p02"]["order"]
	var result := ChronologyRules.validate(state, Session.state.puzzles_contract["p02"])
	if result.get("valid", false):
		Session.state.resolve_puzzle("p02")
		Session.save_now()
		Session.navigate("s02", false)
	else:
		var violations: Array = result.get("violations", [])
		var detail := ""
		if not violations.is_empty():
			detail = str((violations[0] as Dictionary).get("params", {}).get("detail", ""))
		feedback = "Un élément endommagé réapparaît intact plus tard." + ((" Détail : " + DETAIL_NAMES.get(detail, detail)) if not detail.is_empty() else "")
		_rebuild()
