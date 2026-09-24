extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")
const GameStateScript = preload("res://src/core/game_state.gd")

var failures: Array[String] = []

func _init() -> void:
	var loaded := ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "contracts load")
	if not loaded.get("ok", false):
		_finish()
		return
	_test_initial_values(loaded["data"])
	_test_branch_order(loaded["data"], ["p03", "p04"])
	_test_branch_order(loaded["data"], ["p04", "p03"])
	_test_atomic_cargo(loaded["data"])
	_finish()

func _fresh(data: Dictionary) -> Node:
	var state := GameStateScript.new()
	state.configure(data)
	state.new_campaign("test")
	return state

func _solve_prefix(state: Node) -> void:
	_expect(state.resolve_puzzle("p00").get("ok", false), "solve p00")
	_expect(state.resolve_puzzle("p01").get("ok", false), "solve p01")
	preload("res://tests/campaign_fixture.gd").solve_added(state,["p08","p09"])
	_expect(state.resolve_puzzle("p02").get("ok", false), "solve p02")

func _test_initial_values(data: Dictionary) -> void:
	var state := _fresh(data)
	_expect_eq(state.campaign["puzzles"]["p01"]["order"], data["puzzles"]["p01"]["initial"], "p01 initial from JSON")
	_expect_eq(state.campaign["puzzles"]["p02"]["order"], data["puzzles"]["p02"]["initial"], "p02 initial from JSON")
	_expect_eq(state.campaign["puzzles"]["p03"]["bits"], data["puzzles"]["p03"]["initial"], "p03 initial from JSON")
	_expect_eq(state.campaign["puzzles"]["p04"]["turns"], data["puzzles"]["p04"]["initial"], "p04 initial from JSON")
	_expect("evidence_report" in state.available_evidence(), "report available at start")
	_expect("evidence_map" not in state.available_evidence(), "map gated by p00")
	state.resolve_puzzle("p00")
	_expect("evidence_map" in state.available_evidence(), "map granted by prerequisite, no dialogue read")

func _test_branch_order(data: Dictionary, order: Array) -> void:
	var state := _fresh(data)
	_solve_prefix(state)
	for puzzle_id: Variant in order:
		var result: Dictionary = state.resolve_puzzle(str(puzzle_id))
		_expect(result.get("ok", false), "branch solve %s" % puzzle_id)
	_expect(state.can_enter("p10"), "packing unlocked after both branches")
	_expect("evidence_cargo" in state.available_evidence(), "cargo evidence available after both branches")
	var pending: Array = state.campaign["narrative"]["pending"]
	_expect_eq(pending.count("n03"), 1, "n03 queued once")
	_expect_eq(pending.count("n04"), 1, "n04 queued once")
	_expect_eq(pending.count("n05"), 1, "n05 queued once")
	var again: Dictionary = state.resolve_puzzle(str(order[1]))
	_expect(again.get("ok", false) and not again.get("changed", true), "resolution idempotent")
	_expect_eq(state.campaign["narrative"]["pending"].count("n05"), 1, "n05 remains unique")

func _test_atomic_cargo(data: Dictionary) -> void:
	var state := _fresh(data)
	var before: Array = state.campaign["puzzles"]["p05"]["slots"].duplicate()
	var rejected: Dictionary = state.place_cargo("press", 0)
	_expect(not rejected.get("ok", true), "press rejected outside central slot")
	_expect_eq(state.campaign["puzzles"]["p05"]["slots"], before, "rejected placement does not mutate")
	_expect(state.place_cargo("press", 2).get("ok", false), "press can enter left inner")
	_expect(state.place_cargo("lantern", 3).get("ok", false), "lantern can enter right inner")
	var before_swap: Array = state.campaign["puzzles"]["p05"]["slots"].duplicate()
	var rejected_swap: Dictionary = state.place_cargo("medicine", 2)
	_expect(rejected_swap.get("ok", false), "medicine may displace press to tray")
	_expect(state.campaign["puzzles"]["p05"]["slots"] != before_swap, "valid placement commits atomically")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _finish() -> void:
	if failures.is_empty():
		print("T03 STATE TEST PASS: branch orders, evidence grants and idempotence")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
