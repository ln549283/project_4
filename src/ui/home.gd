extends Control
const UiFactory = preload("res://src/ui/ui_factory.gd")

func _ready() -> void:
	Session.router.current_view = "s00"
	UiFactory.apply_root_theme(self, Session.font_size_px())
	var box := UiFactory.make_page(self, "", "")
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 440
	box.add_child(spacer)
	var title := UiFactory.make_label("Les Rives\npliées", 104)
	title.add_theme_font_override("font", preload("res://assets/slice/lantern/title.ttf"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var subtitle := UiFactory.make_label("Dépliez une ville.\nRetrouvez le chemin de ceux qu'elle a sauvés.", 44)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)
	var gap := Control.new()
	gap.custom_minimum_size.y = 84
	box.add_child(gap)
	if Session.has_saved_campaign():
		box.add_child(UiFactory.make_button("Reprendre la restauration", func(): Session.continue_game(), true))
	box.add_child(UiFactory.make_button("Commencer l'histoire" if not Session.has_saved_campaign() else "Nouvelle partie", _new_game, true))
	var links := HBoxContainer.new()
	links.add_theme_constant_override("separation", 24)
	box.add_child(links)
	links.add_child(UiFactory.make_button("Réglages", func(): Session.navigate("s01")))
	links.add_child(UiFactory.make_button("Générique", func(): Session.navigate("s14")))
	var backdrop := get_node("RoomBackdrop")
	backdrop.shade = 0.28
	backdrop.queue_redraw()
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
