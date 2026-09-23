extends "res://src/ui/puzzle_screen_base.gd"

const CargoRules = preload("res://src/rules/cargo_rules.gd")
const SLOT_NAMES := ["Gauche extérieur", "Gauche milieu", "Gauche intérieur", "Droite intérieur", "Droite milieu", "Droite extérieur"]

var selected_item := ""

func _ready() -> void:
	Session.router.current_view = "s09"
	_rebuild()

func _rebuild() -> void:
	clear_page()
	var box := setup_page("Barge", "Stabiliser la cargaison")
	var contract: Dictionary = Session.state.puzzles_contract["p05"]
	var slots: Array = Session.state.campaign["puzzles"]["p05"]["slots"]
	var weights: Dictionary = contract["weights"]
	box.add_child(UiFactory.make_label("Embarquer les six charges. La barge doit rester horizontale.", Session.font_size_px(18)))
	box.add_child(UiFactory.make_label("Lanterne et presse doivent occuper les deux berceaux centraux : elles sont trop hautes pour les arceaux extérieurs.", Session.font_size_px(16)))
	var moment := CargoRules.calculate_moment(slots, contract["positions"], weights)
	var balance_text := "Horizontal" if moment == 0 else ("Penche à droite" if moment > 0 else "Penche à gauche")
	box.add_child(UiFactory.make_label("Aiguille : %s" % balance_text, Session.font_size_px(18)))
	if not selected_item.is_empty():
		box.add_child(UiFactory.make_label("Sélection : %s (masse %d)" % [contract["labels"][selected_item], int(weights[selected_item])], Session.font_size_px(16)))

	box.add_child(UiFactory.make_label("Plateau", Session.font_size_px(18)))
	for raw_item: Variant in weights.keys():
		var item := str(raw_item)
		if item not in slots:
			box.add_child(UiFactory.make_button("%s — masse %d" % [contract["labels"][item], int(weights[item])], _select_item.bind(item)))

	box.add_child(UiFactory.make_label("Berceaux — distances −3, −2, −1, +1, +2, +3", Session.font_size_px(18)))
	for i in range(slots.size()):
		var occupant: Variant = slots[i]
		var label := "%s (%+d) : %s" % [SLOT_NAMES[i], int(contract["positions"][i]), "vide" if occupant == null else str(contract["labels"][str(occupant)])]
		box.add_child(UiFactory.make_button(label, _slot_pressed.bind(i)))
	if not selected_item.is_empty() and selected_item in slots:
		box.add_child(UiFactory.make_button("Retourner la charge sélectionnée au plateau", _return_selected))

	box.add_child(UiFactory.make_button("Comparer les côtés", _compare_sides))
	add_common_tools(
		box,
		"p05",
		_verify,
		func(): ask_reset(_reset_confirmed),
		_undo,
		"Chaque charge agit selon sa masse et sa distance au pivot. Les positions sont −3, −2, −1, +1, +2, +3. Les six charges sont obligatoires."
	)

func _select_item(item: String) -> void:
	selected_item = item
	feedback = ""
	_rebuild()

func _slot_pressed(index: int) -> void:
	var slots: Array = Session.state.campaign["puzzles"]["p05"]["slots"]
	if selected_item.is_empty():
		if slots[index] != null:
			selected_item = str(slots[index])
			_rebuild()
		return
	history.append(slots.duplicate())
	var result: Dictionary = Session.state.place_cargo(selected_item, index)
	if result.get("ok", false):
		Session.save_now()
		feedback = ""
	else:
		history.pop_back()
		feedback = "Trop haut pour cet arceau." if result.get("error") in ["gauge_rejected", "atomic_exchange_rejected"] else "Placement refusé."
	selected_item = ""
	_rebuild()

func _return_selected() -> void:
	if selected_item.is_empty():
		return
	var slots: Array = Session.state.campaign["puzzles"]["p05"]["slots"]
	history.append(slots.duplicate())
	var result := Session.state.place_cargo(selected_item, -1)
	if result.get("ok", false):
		Session.save_now()
	else:
		history.pop_back()
	selected_item = ""
	_rebuild()

func _compare_sides() -> void:
	var contract: Dictionary = Session.state.puzzles_contract["p05"]
	var slots: Array = Session.state.campaign["puzzles"]["p05"]["slots"]
	var parts: Array[String] = []
	for i in range(slots.size()):
		var occupant: Variant = slots[i]
		if occupant != null:
			var item := str(occupant)
			var contribution := int(contract["positions"][i]) * int(contract["weights"][item])
			parts.append("%s : %+d" % [contract["labels"][item], contribution])
	feedback = "Contributions au pivot : " + ("aucune charge posée" if parts.is_empty() else " · ".join(parts))
	_rebuild()

func _undo() -> void:
	if history.is_empty():
		feedback = "Aucun geste à annuler."
	else:
		Session.state.campaign["puzzles"]["p05"]["slots"] = history.pop_back()
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	selected_item = ""
	_rebuild()

func _reset_confirmed() -> void:
	Session.state.reset_unsolved_puzzle("p05")
	Session.save_now()
	history.clear()
	selected_item = ""
	feedback = ""
	_rebuild()

func _verify() -> void:
	var result := CargoRules.validate(Session.state.campaign["puzzles"]["p05"]["slots"], Session.state.puzzles_contract["p05"])
	if result.get("valid", false):
		Session.state.resolve_puzzle("p05")
		Session.save_now()
		Session.navigate("s02", false)
	else:
		var violation: Dictionary = (result.get("violations", []) as Array)[0]
		match str(violation.get("rule_id", "")):
			"p05_missing_cargo", "p05_all_cargo", "p05_all_slots":
				feedback = "Toutes les charges doivent être embarquées."
			"p05_central_gauge":
				feedback = "Lanterne et presse doivent rester dans les deux berceaux centraux."
			"p05_unbalanced":
				feedback = "La barge n'est pas horizontale."
			_:
				feedback = "Le chargement ne respecte pas encore toutes les contraintes."
		_rebuild()
