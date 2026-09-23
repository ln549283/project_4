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
	_expect(ResourceLoader.exists("res://scenes/puzzles/p03.tscn"), "p03 scene exists")
	_expect(ResourceLoader.exists("res://scenes/puzzles/p04.tscn"), "p04 scene exists")
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
		print("T07 BRANCH TEST PASS: independent branches and join")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
