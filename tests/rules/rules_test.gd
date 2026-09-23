extends SceneTree

const PanoramaRules = preload("res://src/rules/panorama_rules.gd")
const ChronologyRules = preload("res://src/rules/chronology_rules.gd")
const RoutesRules = preload("res://src/rules/routes_rules.gd")
const MasksRules = preload("res://src/rules/masks_rules.gd")
const CargoRules = preload("res://src/rules/cargo_rules.gd")
const FloodMapRules = preload("res://src/rules/flood_map_rules.gd")
const SequenceRules = preload("res://src/rules/sequence_rules.gd")

var failures: Array[String] = []

func _init() -> void:
	var data := _load_json("res://design/puzzles.json")
	if data.is_empty():
		_fail("puzzles.json must load")
		_finish()
		return
	_test_p01(data)
	_test_p02(data)
	_test_p03(data)
	_test_p04(data)
	_test_p05(data)
	_test_p06(data)
	_test_p07(data)
	_finish()

func _test_p01(data: Dictionary) -> void:
	var contract: Dictionary = data["p01"]
	var accepted := 0
	for order: Variant in _permutations(contract["pieces"].keys()):
		if PanoramaRules.validate(order, contract).get("valid", false):
			accepted += 1
	_expect_eq(accepted, 1, "p01 accepted_count")
	_expect(PanoramaRules.validate(contract["solution"], contract).get("valid", false), "p01 canonical solution")

func _test_p02(data: Dictionary) -> void:
	var contract: Dictionary = data["p02"]
	var accepted := 0
	for order: Variant in _permutations(contract["observations"].keys()):
		if ChronologyRules.validate(order, contract).get("valid", false):
			accepted += 1
	_expect_eq(accepted, 1, "p02 accepted_count")
	_expect(ChronologyRules.validate(contract["solution"], contract).get("valid", false), "p02 canonical solution")

func _test_p03(data: Dictionary) -> void:
	var contract: Dictionary = data["p03"]
	var accepted := 0
	for state in range(64):
		var bits: Array = []
		for i in range(6):
			bits.append((state >> i) & 1)
		if RoutesRules.validate(bits, contract, data["route_tile_pairs"]).get("valid", false):
			accepted += 1
	_expect_eq(accepted, 1, "p03 accepted_count")
	_expect(RoutesRules.validate(contract["solution"], contract, data["route_tile_pairs"]).get("valid", false), "p03 canonical solution")

func _test_p04(data: Dictionary) -> void:
	var contract: Dictionary = data["p04"]
	var accepted := 0
	for a in range(4):
		for b in range(4):
			for c in range(4):
				if MasksRules.validate([a, b, c], contract).get("valid", false):
					accepted += 1
	_expect_eq(accepted, 1, "p04 accepted_count")
	_expect(MasksRules.validate(contract["solution"], contract).get("valid", false), "p04 canonical solution")

func _test_p05(data: Dictionary) -> void:
	var contract: Dictionary = data["p05"]
	var accepted := 0
	for order: Variant in _permutations(contract["weights"].keys()):
		if CargoRules.validate(order, contract).get("valid", false):
			accepted += 1
	_expect_eq(accepted, 4, "p05 accepted_count")
	_expect(CargoRules.validate(contract["example_solution"], contract).get("valid", false), "p05 example solution")

func _test_p06(data: Dictionary) -> void:
	var contract: Dictionary = data["p06"]
	var base_routes: Dictionary = contract["solution"]["routes"].duplicate(true)
	var accepted_maps := 0
	var arcade_choices: Array = [null]
	arcade_choices.append_array(contract["fragments"]["arcade"]["destinations"])
	var ramp_choices: Array = [null]
	ramp_choices.append_array(contract["fragments"]["ramp"]["destinations"])
	for water: Variant in contract["water_levels"]:
		for arcade: Variant in arcade_choices:
			for ramp: Variant in ramp_choices:
				var state := {
					"water_level": water,
					"fragments": {"arcade": arcade, "ramp": ramp},
					"routes": base_routes.duplicate(true),
				}
				if FloodMapRules.validate(state, contract).get("valid", false):
					accepted_maps += 1
	_expect_eq(accepted_maps, 1, "p06 map accepted_count with canonical routes")
	var state_a := {
		"water_level": 4,
		"fragments": {"arcade": "jk", "ramp": "kl"},
		"routes": {
			"school": ["S", "J", "K", "C"],
			"infirmary": ["I", "J", "K", "L", "H"],
			"archives": ["A", "J", "K", "L", "G"],
		},
	}
	var state_b: Dictionary = state_a.duplicate(true)
	state_b["routes"]["archives"] = ["A", "J", "K", "H", "L", "G"]
	_expect(FloodMapRules.validate(state_a, contract).get("valid", false), "p06 archives variant A")
	_expect(FloodMapRules.validate(state_b, contract).get("valid", false), "p06 archives variant B")
	var wrong := state_a.duplicate(true)
	wrong["fragments"] = {"arcade": "sc", "ramp": "ag"}
	_expect(not FloodMapRules.validate(wrong, contract).get("valid", true), "p06 isolated shortcuts rejected")
	var low_water := state_a.duplicate(true)
	low_water["water_level"] = 3
	low_water["fragments"] = {"arcade": null, "ramp": null}
	low_water["routes"]["infirmary"] = ["I", "H"]
	_expect(not FloodMapRules.validate(low_water, contract).get("valid", true), "p06 wrong water rejected even if shortcut opens")

func _test_p07(data: Dictionary) -> void:
	var contract: Dictionary = data["p07"]
	var accepted := 0
	for sequence: Variant in _permutations(contract["actions"]):
		if SequenceRules.validate_sequence(sequence, contract).get("valid", false):
			accepted += 1
	_expect_eq(accepted, 1, "p07 accepted_count")
	_expect(SequenceRules.validate("floor", contract["solution"], contract).get("valid", false), "p07 floor and sequence")
	_expect(not SequenceRules.validate_donor("roof", contract).get("valid", true), "p07 roof rejected")
	_expect(not SequenceRules.validate_donor("door", contract).get("valid", true), "p07 door rejected")

func _permutations(values: Array) -> Array:
	if values.size() <= 1:
		return [values.duplicate()]
	var result: Array = []
	for i in range(values.size()):
		var rest := values.duplicate()
		var head: Variant = rest.pop_at(i)
		for tail: Variant in _permutations(rest):
			var row: Array = [head]
			row.append_array(tail)
			result.append(row)
	return result

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_fail("%s expected=%s actual=%s" % [message, expected, actual])

func _fail(message: String) -> void:
	failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("T02 RULE TEST PASS: counts and variants match design/verification_report.json")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
