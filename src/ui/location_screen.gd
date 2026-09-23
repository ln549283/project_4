extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

@export var view_id := "s02"
@export var screen_title := "Établi"
var p00_message := ""

func _ready() -> void:
	Session.router.current_view = view_id
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, screen_title, Session.current_objective())
	if view_id == "s02" and "p00" not in Session.state.campaign.get("solved", []):
		_build_p00(box)
	else:
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

func _build_p00(box: VBoxContainer) -> void:
	box.add_child(UiFactory.make_label("Prise en main — Soulever les deux attaches, puis ouvrir.", Session.font_size_px(18)))
	var latches: Array = Session.state.campaign["puzzles"]["p00"]["latches"]
	box.add_child(UiFactory.make_button("Attache gauche : " + ("ouverte" if bool(latches[0]) else "fermée"), _toggle_latch.bind(0)))
	box.add_child(UiFactory.make_button("Attache droite : " + ("ouverte" if bool(latches[1]) else "fermée"), _toggle_latch.bind(1)))
	box.add_child(UiFactory.make_button("Ouvrir le coffret", _open_box))
	if not p00_message.is_empty():
		box.add_child(UiFactory.make_label(p00_message, Session.font_size_px(16)))

func _toggle_latch(index: int) -> void:
	Session.state.toggle_latch(index)
	Session.save_now()
	_rebuild()

func _open_box() -> void:
	var result: Dictionary = Session.state.open_box()
	if result.get("ok", false):
		Session.save_now()
		Session.navigate("s05")
	else:
		p00_message = "Une attache retient encore le couvercle."
		_rebuild()

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
