extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	Session.router.current_view = "s01"
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, "Réglages")
	box.add_child(UiFactory.make_label("Taille du texte", Session.font_size_px(18)))
	box.add_child(UiFactory.make_button("100 %", func(): _scale(1.0)))
	box.add_child(UiFactory.make_button("125 %", func(): _scale(1.25)))
	box.add_child(UiFactory.make_button("150 %", func(): _scale(1.5)))
	box.add_child(UiFactory.make_button(_toggle_label("Vibrations", "vibration"), func(): _toggle("vibration")))
	box.add_child(UiFactory.make_button(_toggle_label("Mouvement réduit", "reduced_motion"), func(): _toggle("reduced_motion")))
	box.add_child(UiFactory.make_button(_toggle_label("Contraste renforcé", "high_contrast"), func(): _toggle("high_contrast")))
	box.add_child(UiFactory.make_button("Retour", _back, true))

func _scale(value: float) -> void:
	Session.set_text_scale(value)
	_rebuild()

func _toggle(key: String) -> void:
	Session.toggle_setting(key)
	_rebuild()

func _toggle_label(label: String, key: String) -> String:
	return "%s : %s" % [label, "Activé" if bool(Session.settings.get(key, false)) else "Désactivé"]

func _back() -> void:
	if not Session.go_back().get("ok", false):
		Session.navigate("s00", false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		get_viewport().set_input_as_handled()
