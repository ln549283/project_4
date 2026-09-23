extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const P03ShutterBoard = preload("res://src/ui/p03_shutter_board.gd")
const P04MaskPreview = preload("res://src/ui/p04_mask_preview.gd")

var failures: Array[String] = []

func _init() -> void:
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	_expect(ResourceLoader.exists("res://scenes/puzzles/p03.tscn"), "p03 scene exists")
	_expect(ResourceLoader.exists("res://scenes/puzzles/p04.tscn"), "p04 scene exists")
	var p03_contract: Dictionary = loaded["data"]["puzzles"]["p03"]
	var board := P03ShutterBoard.new()
	board.size = Vector2(984, 880)
	board.configure(p03_contract["initial"], p03_contract, loaded["data"]["puzzles"]["route_tile_pairs"], "")
	board._rebuild_geometry()
	_expect_eq(board.tile_rects.size(), 6, "p03 greybox exposes six visual shutters")
	_expect_eq(board.route_hit_rects.size(), 3, "p03 greybox exposes three tappable departures")
	for rect: Rect2 in board.tile_rects:
		_expect(rect.size.x >= 144.0 and rect.size.y >= 144.0, "p03 shutters keep minimum touch size")
	for route_id: Variant in board.route_hit_rects:
		var route_rect: Rect2 = board.route_hit_rects[route_id]
		_expect(route_rect.size.y >= 144.0, "p03 departure keeps minimum touch height")
	_expect_eq(board.bits, p03_contract["initial"], "p03 presentation does not alter initial logic")
	board.free()
	var p04_contract: Dictionary = loaded["data"]["puzzles"]["p04"]
	var p04_preview := P04MaskPreview.new()
	p04_preview.size = Vector2(700, 520)
	p04_preview.configure(p04_contract["masks"][0], p04_contract["target"], true)
	_expect_eq(p04_preview.current, p04_contract["masks"][0], "p04 visual preview preserves mask data")
	_expect_eq(p04_preview.target, p04_contract["target"], "p04 visual preview preserves target data")
	p04_preview.free()
	for order in [["p03", "p04"], ["p04", "p03"]]:
		var state := GameStateScript.new()
		state.configure(loaded["data"])
		state.new_campaign("t07")
		for prefix in ["p00", "p01", "p02"]:
			_expect(state.resolve_puzzle(prefix).get("ok", false), "resolve prefix " + prefix)
		for stage: Variant in order:
			_expect(state.resolve_puzzle(str(stage)).get("ok", false), "resolve branch " + str(stage))
		_expect(state.can_enter("p05"), "p05 unlocked after either branch order")
		_expect("evidence_cargo" in state.available_evidence(), "cargo evidence available at join")
		_expect_eq(state.campaign["narrative"]["pending"].count("n05"), 1, "n05 queued once")
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _finish() -> void:
	if failures.is_empty():
		print("T07 BRANCH TEST PASS: independent branches, visual P03/P04 greybox and join")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
