extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	Session.router.current_view = "s00"
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, "Les Rives pliées", "Dépliez une ville. Retrouvez le chemin de ceux qu'elle a sauvés.")
	box.add_child(UiFactory.make_button("La lanterne · séquence premium", _open_lantern, true))
	if Session.has_saved_campaign():
		box.add_child(UiFactory.make_button("Continuer", func(): Session.continue_game(), true))
	box.add_child(UiFactory.make_button("Nouvelle partie", _new_game, true))
	box.add_child(UiFactory.make_button("Réglages", func(): Session.navigate("s01"), true))
	box.add_child(UiFactory.make_button("Générique", func(): Session.navigate("s14"), true))
	if not Session.recovery_message.is_empty():
		box.add_child(UiFactory.make_label(Session.recovery_message, Session.font_size_px(16)))

func _new_game() -> void:
	if Session.has_saved_campaign():
		var dialog := preload("res://scenes/ui/confirm.tscn").instantiate()
		dialog.configure(
			"Nouvelle partie",
			"Recommencer effacera la partie actuelle. Une sauvegarde de secours sera conservée.",
			"Recommencer",
			"Garder ma partie",
			func(): Session.start_new_game()
		)
		add_child(dialog)
	else:
		var result: Dictionary = Session.start_new_game()
		if not result.get("ok", false):
			var modal := preload("res://scenes/ui/save_error.tscn").instantiate()
			modal.configure("Nouvelle partie impossible", str(result.get("error", "Erreur inconnue")))
			add_child(modal)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _open_lantern() -> void:
	if Session.presentation_audio != null: Session.presentation_audio.set_slice_active(true)
	get_tree().change_scene_to_file("res://scenes/slice/lantern.tscn")
