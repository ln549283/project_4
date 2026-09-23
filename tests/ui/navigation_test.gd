extends SceneTree

const SceneRouterClass = preload("res://src/core/scene_router.gd")
const UiFactory = preload("res://src/ui/ui_factory.gd")

var failures: Array[String] = []

func _init() -> void:
	var routes := {
		"s00": "res://scenes/home.tscn",
		"s01": "res://scenes/settings.tscn",
		"s02": "res://scenes/workbench.tscn",
		"s03": "res://scenes/archive.tscn",
		"s04": "res://scenes/window.tscn",
		"s12": "res://scenes/ui/notebook.tscn",
		"s14": "res://scenes/credits.tscn",
	}
	var router := SceneRouterClass.new(routes)
	for view_id: Variant in routes:
		_expect(ResourceLoader.exists(routes[view_id]), "scene exists " + str(view_id))
	_expect(router.replace("s02").get("ok", false), "replace s02")
	_expect(router.push("s03").get("ok", false), "push s03")
	_expect(router.push("s12").get("ok", false), "push notebook")
	var back := router.back()
	_expect_eq(back.get("view_id"), "s03", "notebook back restores exact parent")
	back = router.back()
	_expect_eq(back.get("view_id"), "s02", "archive back restores workbench")
	_expect(not router.push("s99").get("ok", true), "unknown route rejected")
	var button := UiFactory.make_button("Test", func(): pass)
	_expect(button.custom_minimum_size.y >= 144.0, "touch target >= 48dp at 3px/dp")
	var nav := UiFactory.make_button("Nav", func(): pass, true)
	_expect(nav.custom_minimum_size.y >= 168.0, "navigation target >= 56dp")
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _expect_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, expected, actual])

func _finish() -> void:
	if failures.is_empty():
		print("T05 NAV TEST PASS: routes, back stack and minimum touch targets")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
