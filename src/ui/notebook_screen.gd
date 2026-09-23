extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	Session.router.current_view = "s12"
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, "Carnet", Session.current_objective())
	var available: Array = Session.state.available_evidence()
	for raw_id: Variant in available:
		var evidence_id := str(raw_id)
		var prefix := "[Épinglée] " if Session.view_state.get("pinned_evidence") == evidence_id else ""
		box.add_child(UiFactory.make_button(prefix + evidence_id, _open_evidence.bind(evidence_id)))
	if available.is_empty():
		box.add_child(UiFactory.make_label("Aucune preuve disponible.", Session.font_size_px(16)))
	var compare: Array = Session.view_state.get("compare_evidence", [])
	if not compare.is_empty():
		box.add_child(UiFactory.make_label("Comparaison : " + " / ".join(compare), Session.font_size_px(16)))
	box.add_child(UiFactory.make_button("Fermer", _back, true))

func _open_evidence(evidence_id: String) -> void:
	var item := Session.evidence_item(evidence_id)
	var overlay := preload("res://scenes/ui/evidence_detail.tscn").instantiate()
	overlay.configure(evidence_id, str(item.get("body", item.get("content_contract", ""))))
	get_tree().current_scene.add_child(overlay)

func _back() -> void:
	if not Session.close_notebook().get("ok", false):
		Session.navigate("s02", false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		get_viewport().set_input_as_handled()
