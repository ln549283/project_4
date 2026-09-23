extends "res://src/ui/puzzle_screen_base.gd"

const FloodMapRules = preload("res://src/rules/flood_map_rules.gd")\nconst P06MapBoard = preload("res://src/ui/p06_map_board.gd")
const GROUP_NAMES := {"school": "École", "infirmary": "Infirmerie / brancard", "archives": "Archives"}

var active_group := "school"
var zoomed := false

func _ready() -> void:
	Session.router.current_view = "s10"
	_rebuild()

func _rebuild() -> void:
	clear_page()
	var box := setup_page("Quartier sous l'eau", "Relier les groupes aux refuges")
	var contract: Dictionary = Session.state.puzzles_contract["p06"]
	var state: Dictionary = Session.state.campaign["puzzles"]["p06"]
	box.add_child(UiFactory.make_label("F3 montre l'eau au repère 4. Une liaison est inaccessible lorsque l'eau atteint sa marque.", Session.font_size_px(18)))
	box.add_child(UiFactory.make_label("Deux liaisons bâties ; les autres blancs sont des bras d'eau. Les trajets peuvent partager un passage.", Session.font_size_px(16)))

	box.add_child(UiFactory.make_label("Niveau d'eau actuel : %d" % int(state["water_level"]), Session.font_size_px(18)))
	var water_row := HBoxContainer.new()
	water_row.add_theme_constant_override("separation", 12)
	for level in contract["water_levels"]:
		water_row.add_child(UiFactory.make_button(str(level), _set_water.bind(int(level))))
	box.add_child(water_row)

	box.add_child(UiFactory.make_label("Fragments de carte", Session.font_size_px(18)))
	_build_fragment_controls(box, "arcade")
	_build_fragment_controls(box, "ramp")

	box.add_child(UiFactory.make_button("Agrandir / réduire le plan", _toggle_zoom))
	var map_board := P06MapBoard.new()
	map_board.configure(state, contract, active_group, zoomed)
	map_board.node_pressed.connect(_node_pressed)
	box.add_child(map_board)

	box.add_child(UiFactory.make_label("Parcours", Session.font_size_px(18)))
	for group_id in ["school", "infirmary", "archives"]:
		var suffix := " [actif]" if active_group == group_id else ""
		box.add_child(UiFactory.make_button(GROUP_NAMES[group_id] + suffix, _select_group.bind(group_id)))
	for group_id in ["school", "infirmary", "archives"]:
		var route: Array = state["routes"][group_id]
		box.add_child(UiFactory.make_label("%s : %s" % [GROUP_NAMES[group_id], _route_text(route)], Session.font_size_px(16)))

	_build_route_controls(box)
	add_common_tools(
		box,
		"p06",
		_verify,
		func(): ask_reset(_reset_confirmed),
		_undo,
		"Réglez l'eau, placez l'arcade et la rampe, puis construisez trois chemins simples. Le brancard ne peut pas emprunter les marches."
	)

func _build_fragment_controls(box: VBoxContainer, fragment_id: String) -> void:
	var contract: Dictionary = Session.state.puzzles_contract["p06"]
	var current: Variant = Session.state.campaign["puzzles"]["p06"]["fragments"][fragment_id]
	var name := str(contract["fragments"][fragment_id]["label"])
	box.add_child(UiFactory.make_label("%s : %s" % [name, "non placé" if current == null else _gap_label(str(current))], Session.font_size_px(16)))
	box.add_child(UiFactory.make_button("Retirer " + name, _place_fragment.bind(fragment_id, null)))
	for raw_gap: Variant in contract["fragments"][fragment_id]["destinations"]:
		var gap_id := str(raw_gap)
		box.add_child(UiFactory.make_button("%s → %s" % [name, _gap_label(gap_id)], _place_fragment.bind(fragment_id, gap_id)))

func _gap_label(gap_id: String) -> String:
	var gap: Dictionary = Session.state.puzzles_contract["p06"]["gaps"][gap_id]
	var ends: Array = gap["ends"]
	return "%s–%s" % [_node_label(str(ends[0])), _node_label(str(ends[1]))]

func _node_label(node_id: String) -> String:
	return str(Session.state.puzzles_contract["p06"]["nodes"][node_id]["label"])

func _build_route_controls(box: VBoxContainer) -> void:
	var contract: Dictionary = Session.state.puzzles_contract["p06"]
	var route: Array = Session.state.campaign["puzzles"]["p06"]["routes"][active_group]
	var group: Dictionary = contract["groups"][active_group]
	if route.is_empty():
		box.add_child(UiFactory.make_button("Commencer à " + _node_label(str(group["start"])), _node_pressed.bind(str(group["start"]))))
		return
	box.add_child(UiFactory.make_label("Prochains lieux depuis " + _node_label(str(route[-1])), Session.font_size_px(16)))
	for node_id in _neighbors(str(route[-1])):
		box.add_child(UiFactory.make_button(_node_label(node_id), _node_pressed.bind(node_id)))
	if route.size() > 1:
		box.add_child(UiFactory.make_label("Revenir à un lieu déjà atteint :", Session.font_size_px(16)))
		for raw_node: Variant in route:
			var node_id := str(raw_node)
			box.add_child(UiFactory.make_button(_node_label(node_id), _node_pressed.bind(node_id)))

func _neighbors(node_id: String) -> Array[String]:
	var result: Array[String] = []
	var state: Dictionary = Session.state.campaign["puzzles"]["p06"]
	var contract: Dictionary = Session.state.puzzles_contract["p06"]
	for raw_edge: Variant in FloodMapRules.active_edges(state["fragments"], contract):
		var edge: Dictionary = raw_edge
		var ends: Array = edge["ends"]
		if str(ends[0]) == node_id and str(ends[1]) not in result:
			result.append(str(ends[1]))
		elif str(ends[1]) == node_id and str(ends[0]) not in result:
			result.append(str(ends[0]))
	return result

func _node_pressed(node_id: String) -> void:
	var contract: Dictionary = Session.state.puzzles_contract["p06"]
	var group: Dictionary = contract["groups"][active_group]
	var route: Array = Session.state.campaign["puzzles"]["p06"]["routes"][active_group]
	if node_id in route:
		history.append(_snapshot())
		var index := route.find(node_id)
		Session.state.set_route(active_group, route.slice(0, index + 1))
		Session.save_now()
		feedback = ""
		_rebuild()
		return
	if route.is_empty():
		if node_id != str(group["start"]):
			feedback = "Commencez par l'origine du groupe."
			_rebuild()
			return
		history.append(_snapshot())
		Session.state.set_route(active_group, [node_id])
		Session.save_now()
		feedback = ""
		_rebuild()
		return
	if node_id not in _neighbors(str(route[-1])):
		feedback = "Liaison inexistante entre ces deux lieux."
		_rebuild()
		return
	history.append(_snapshot())
	var next := route.duplicate()
	next.append(node_id)
	Session.state.set_route(active_group, next)
	Session.save_now()
	feedback = ""
	_rebuild()

func _route_text(route: Array) -> String:
	if route.is_empty():
		return "non tracé"
	var labels: Array[String] = []
	for raw_node: Variant in route:
		labels.append(_node_label(str(raw_node)))
	return " → ".join(labels)

func _set_water(level: int) -> void:
	history.append(_snapshot())
	Session.state.set_water_level(level)
	Session.save_now()
	feedback = ""
	_rebuild()

func _place_fragment(fragment_id: String, gap_id: Variant) -> void:
	history.append(_snapshot())
	var result := Session.state.place_fragment(fragment_id, gap_id)
	if result.get("ok", false):
		Session.save_now()
		feedback = ""
	else:
		history.pop_back()
		feedback = "Ce fragment ne correspond pas à cet emplacement."
	_rebuild()

func _select_group(group_id: String) -> void:
	active_group = group_id
	feedback = ""
	_rebuild()

func _toggle_zoom() -> void:
	zoomed = not zoomed
	_rebuild()

func _snapshot() -> Dictionary:
	return (Session.state.campaign["puzzles"]["p06"] as Dictionary).duplicate(true)

func _undo() -> void:
	if history.is_empty():
		feedback = "Aucun geste à annuler."
	else:
		Session.state.campaign["puzzles"]["p06"] = history.pop_back()
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	_rebuild()

func _reset_confirmed() -> void:
	Session.state.reset_unsolved_puzzle("p06")
	Session.save_now()
	history.clear()
	active_group = "school"
	zoomed = false
	feedback = ""
	_rebuild()

func _verify() -> void:
	var result := FloodMapRules.validate(Session.state.campaign["puzzles"]["p06"], Session.state.puzzles_contract["p06"])
	if result.get("valid", false):
		Session.state.resolve_puzzle("p06")
		Session.save_now()
		Session.navigate("s02", false)
		return
	var violations: Array = result.get("violations", [])
	var rule_id := "" if violations.is_empty() else str((violations[0] as Dictionary).get("rule_id", ""))
	match rule_id:
		"p06_water_level":
			feedback = "La hauteur d'eau ne correspond pas à la dernière photographie."
		"p06_fragment_missing", "p06_fragment_incompatible":
			feedback = "Un fragment est absent ou ne correspond pas à ses coutures."
		"p06_origin_or_destination":
			feedback = "Un parcours n'a pas encore la bonne origine et la bonne destination."
		"p06_missing_link":
			feedback = "Un segment emprunte une liaison inexistante."
		"p06_flooded_link":
			feedback = "Un segment emprunte une liaison noyée à cette hauteur."
		"p06_stairs_forbidden":
			feedback = "Le groupe au brancard ne peut pas emprunter les marches."
		_:
			feedback = "Un parcours ne respecte pas encore les règles du plan."
	_rebuild()
