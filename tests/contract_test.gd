extends SceneTree

const ContractLoader = preload("res://src/core/contract_loader.gd")

var failures: Array[String] = []

func _init() -> void:
	var loaded: Dictionary = ContractLoader.load_and_validate()
	_expect(loaded.get("ok", false), "canonical contracts must validate")
	if loaded.get("ok", false):
		var data: Dictionary = loaded["data"]
		var invalid_hints: Dictionary = (data["hints"] as Dictionary).duplicate(true)
		invalid_hints["p01"] = ["indice incomplet"]
		var rejected_hints := ContractLoader.validate_contracts(
			(data["puzzles"] as Dictionary).duplicate(true),
			(data["evidence"] as Dictionary).duplicate(true),
			invalid_hints
		)
		_expect(not rejected_hints.get("ok", true), "invalid hints contract must be rejected")
		_expect(_contains_prefix(rejected_hints.get("errors", []), "hints.expected_three:p01"), "invalid hints rejection must be explicit")

		var invalid_puzzles: Dictionary = (data["puzzles"] as Dictionary).duplicate(true)
		invalid_puzzles["progression"]["p05"] = ["p03", "unknown_stage"]
		var rejected_prereq := ContractLoader.validate_contracts(
			invalid_puzzles,
			(data["evidence"] as Dictionary).duplicate(true),
			(data["hints"] as Dictionary).duplicate(true)
		)
		_expect(not rejected_prereq.get("ok", true), "unknown prerequisite contract must be rejected")
		_expect(_contains_prefix(rejected_prereq.get("errors", []), "progression_unknown_prerequisite:p05->unknown_stage"), "unknown prerequisite rejection must be explicit")

	if failures.is_empty():
		print("T01 CONTRACT TEST PASS: canonical contracts accepted; invalid contracts refused explicitly")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _contains_prefix(values: Array, expected: String) -> bool:
	for value: Variant in values:
		if str(value) == expected:
			return true
	return false
