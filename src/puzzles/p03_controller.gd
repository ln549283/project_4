extends "res://src/ui/puzzle_screen_base.gd"

const RoutesRules = preload("res://src/rules/routes_rules.gd")
const P03ShutterBoard = preload("res://src/ui/p03_shutter_board.gd")
var traced_route := ""

func _ready() -> void:
	Session.router.current_view = "s07"
	_rebuild()

func _rebuild() -> void:
	clear_page()
	var box := setup_page("Chemins de service", "Retrouver les livraisons")
	box.add_child(UiFactory.make_label("Chaque volet contient deux passages séparés. Retournez les volets pour relier les trois départs à leurs arrivées.", Session.font_size_px(18)))
	var bits: Array = Session.state.campaign["puzzles"]["p03"]["bits"]
	var contract: Dictionary = Session.state.puzzles_contract["p03"]
	var board := P03ShutterBoard.new()
	board.configure(bits, contract, Session.state.puzzles_contract["route_tile_pairs"], traced_route)
	board.shutter_pressed.connect(_flip)
	board.route_pressed.connect(_trace)
	box.add_child(board)
	if not traced_route.is_empty():
		box.add_child(UiFactory.make_label(_trace_feedback(traced_route), Session.font_size_px(16)))
	add_common_tools(
		box,
		"p03",
		_verify,
		func(): ask_reset(_reset_confirmed),
		_undo,
		"Face A : Nord–Est et Sud–Ouest. Face B : Nord–Ouest et Sud–Est. Les trois livraisons doivent atteindre leurs destinations simultanément."
	)

func _flip(index: int) -> void:
	history.append((Session.state.campaign["puzzles"]["p03"]["bits"] as Array).duplicate())
	Session.state.flip_tile(index)
	Session.save_now()
	feedback = ""
	_rebuild()

func _trace(route_id: String) -> void:
	traced_route = "" if traced_route == route_id else route_id
	_rebuild()

func _trace_feedback(route_id: String) -> String:
	var contract: Dictionary = Session.state.puzzles_contract["p03"]
	var bits: Array = Session.state.campaign["puzzles"]["p03"]["bits"]
	for raw_route: Variant in contract["routes"]:
		var route: Dictionary = raw_route
		if str(route["id"]) != route_id:
			continue
		var traced := RoutesRules.trace(bits, int(contract["rows"]), int(contract["cols"]), route["start"], Session.state.puzzles_contract["route_tile_pairs"])
		var actual: Array = traced.get("end", [])
		return "%s : arrivée à %s." % [route["start_label"], _endpoint_label(actual)]
	return ""

func _endpoint_label(endpoint: Array) -> String:
	var contract: Dictionary = Session.state.puzzles_contract["p03"]
	for raw_route: Variant in contract["routes"]:
		var route: Dictionary = raw_route
		if endpoint == route["end"]:
			return str(route["end_label"])
		if endpoint == route["start"]:
			return str(route["start_label"])
	return "une berge sans destination"

func _undo() -> void:
	if history.is_empty():
		feedback = "Aucun geste à annuler."
	else:
		Session.state.campaign["puzzles"]["p03"]["bits"] = history.pop_back()
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	_rebuild()

func _reset_confirmed() -> void:
	Session.state.reset_unsolved_puzzle("p03")
	Session.save_now()
	history.clear()
	traced_route = ""
	feedback = ""
	_rebuild()

func _verify() -> void:
	var result := RoutesRules.validate(
		Session.state.campaign["puzzles"]["p03"]["bits"],
		Session.state.puzzles_contract["p03"],
		Session.state.puzzles_contract["route_tile_pairs"]
	)
	if result.get("valid", false):
		Session.state.resolve_puzzle("p03")
		Session.save_now()
		Session.navigate("s02", false)
	else:
		var lines: Array[String] = []
		for raw_route: Variant in Session.state.puzzles_contract["p03"]["routes"]:
			var route: Dictionary = raw_route
			var traced := RoutesRules.trace(Session.state.campaign["puzzles"]["p03"]["bits"], 2, 3, route["start"], Session.state.puzzles_contract["route_tile_pairs"])
			lines.append("%s : arrivée à %s" % [route["start_label"], _endpoint_label(traced.get("end", []))])
		feedback = "\n".join(lines)
		_rebuild()
