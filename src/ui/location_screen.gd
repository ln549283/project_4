extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

@export var view_id := "s02"
@export var screen_title := "Établi"

func _ready() -> void:
	Session.router.current_view = view_id
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, screen_title, Session.current_objective())
	box.add_child(UiFactory.make_button("Continuer le travail", _continue_work, true))
	if view_id != "s02":
		box.add_child(UiFactory.make_button("Établi", func(): Session.navigate("s02"), true))
	if view_id != "s03":
		box.add_child(UiFactory.make_button("Archives", func(): Session.navigate("s03"), true))
	if view_id != "s04":
		box.add_child(UiFactory.make_button("Fenêtre", func(): Session.navigate("s04"), true))
	box.add_child(UiFactory.make_button("Carnet", func(): Session.open_notebook(), true))
	box.add_child(UiFactory.make_button("Réglages", func(): Session.navigate("s01"), true))
	box.add_child(UiFactory.make_button("Pause", _open_pause, true))

func _continue_work() -> void:
	var target := _objective_view()
	if Session.router.has_route(target):
		Session.navigate(target)

func _objective_view() -> String:
	var solved: Array = Session.state.campaign.get("solved", [])
	if "p00" not in solved:
		return "s02"
	if "p01" not in solved:
		return "s05"
	if "p02" not in solved:
		return "s06"
	if "p03" not in solved:
		return "s07"
	if "p04" not in solved:
		return "s08"
	if "p05" not in solved:
		return "s09"
	if "p06" not in solved:
		return "s10"
	if "p07" not in solved:
		return "s11"
	return "s13"

func _open_pause() -> void:
	var overlay := preload("res://scenes/ui/pause.tscn").instantiate()
	get_tree().current_scene.add_child(overlay)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_open_pause()
		get_viewport().set_input_as_handled()
