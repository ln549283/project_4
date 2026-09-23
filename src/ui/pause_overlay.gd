extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.12, 0.14, 0.92)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(bg, "Pause")
	box.add_child(UiFactory.make_button("Reprendre", queue_free, true))
	box.add_child(UiFactory.make_button("Carnet", _notebook, true))
	box.add_child(UiFactory.make_button("Réglages", _settings, true))
	box.add_child(UiFactory.make_button("Accueil", _home, true))

func _notebook() -> void:
	queue_free()
	Session.open_notebook()

func _settings() -> void:
	queue_free()
	Session.navigate("s01")

func _home() -> void:
	Session.save_now()
	Session.router.clear_to("s00")
	get_tree().change_scene_to_file(Session.router.path_for("s00"))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
