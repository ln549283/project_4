extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")
const P01PanoramaBoard = preload("res://src/ui/p01_panorama_board.gd")
const P02PhotoBoard = preload("res://src/ui/p02_photo_board.gd")

var failures: Array[String] = []

func _init() -> void:
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	var state := GameStateScript.new()
	state.configure(loaded["data"])
	state.new_campaign("t06")
	_expect(ResourceLoader.exists("res://scenes/puzzles/p01.tscn"), "p01 scene exists")
	_expect(ResourceLoader.exists("res://scenes/puzzles/p02.tscn"), "p02 scene exists")
	var p01_contract: Dictionary = loaded["data"]["puzzles"]["p01"]
	var p01_board := P01PanoramaBoard.new()
	p01_board.size = Vector2(984, 460)
	p01_board.configure(p01_contract["initial"], p01_contract, -1)
	p01_board._rebuild_geometry()
	_expect_eq(p01_board.piece_rects.size(), 5, "p01 greybox exposes five visual strips")
	_expect_eq(p01_board.order, p01_contract["initial"], "p01 visual board preserves initial order")
	p01_board.free()
	var p02_contract: Dictionary = loaded["data"]["puzzles"]["p02"]
	var p02_board := P02PhotoBoard.new()
	p02_board.size = Vector2(984, 600)
	p02_board.configure(p02_contract["initial"], p02_contract["observations"], -1, [])
	p02_board._rebuild_geometry()
	_expect_eq(p02_board.card_rects.size(), 5, "p02 greybox exposes five visual photos")
	_expect_eq(p02_board.order, p02_contract["initial"], "p02 visual board preserves initial order")
	p02_board.free()
	_expect(not state.open_box().get("ok", true), "box refuses while latches closed")
	_expect(state.toggle_latch(0).get("ok", false), "left latch toggles")
	_expect(not state.open_box().get("ok", true), "one latch still blocks")
	_expect(state.toggle_latch(1).get("ok", false), "right latch toggles")
	_expect(state.open_box().get("ok", false), "box opens with both latches")
	_expect("p00" in state.campaign["solved"], "p00 solved atomically")
	_expect("evidence_map" in state.available_evidence(), "p01 evidence available before p01")
	_expect(state.resolve_puzzle("p01").get("ok", false), "p01 progression resolves")
	for evidence_id in ["evidence_photo_note", "evidence_photo_f4", "evidence_photo_f1", "evidence_photo_f5", "evidence_photo_f2", "evidence_photo_f3"]:
		_expect(evidence_id in state.available_evidence(), "p02 evidence available: " + evidence_id)
	_expect(state.resolve_puzzle("p02").get("ok", false), "p02 progression resolves")
	_expect(state.can_enter("p03"), "p03 unlocked")
	_expect(state.can_enter("p04"), "p04 unlocked")
	_finish()

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("T06 EARLY PUZZLES TEST PASS: P00 gating, visual P01/P02 and progression/evidence")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
