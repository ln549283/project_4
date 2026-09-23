class_name PuzzleScreenBase
extends Control

const UiFactory = preload("res://src/ui/ui_factory.gd")

var history: Array = []
var feedback := ""

func setup_page(title: String, objective: String) -> VBoxContainer:
	UiFactory.apply_root_theme(self, Session.font_size_px())
	return UiFactory.make_page(self, title, objective)

func add_common_tools(box: VBoxContainer, puzzle_id: String, verify_action: Callable, reset_action: Callable, undo_action: Callable, functioning_text: String) -> void:
	box.add_child(UiFactory.make_button("Vérifier", verify_action, true))
	box.add_child(UiFactory.make_button("Annuler", undo_action))
	box.add_child(UiFactory.make_button("Replacer", reset_action))
	box.add_child(UiFactory.make_button("Fonctionnement", func(): _show_functioning(functioning_text)))
	box.add_child(UiFactory.make_button("Indice", func(): _show_hint(puzzle_id)))
	box.add_child(UiFactory.make_button("Carnet", func(): Session.open_notebook()))
	box.add_child(UiFactory.make_button("Retour", _back, true))
	if not feedback.is_empty():
		box.add_child(UiFactory.make_label(feedback, Session.font_size_px(16)))

func clear_page() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func ask_reset(callback: Callable) -> void:
	var dialog := preload("res://scenes/ui/confirm.tscn").instantiate()
	dialog.configure(
		"Replacer",
		"Replacer les éléments de cette énigme ? Vos preuves et indices resteront disponibles.",
		"Replacer",
		"Annuler",
		callback
	)
	add_child(dialog)

func _show_hint(puzzle_id: String) -> void:
	var overlay := preload("res://scenes/ui/hint.tscn").instantiate()
	overlay.configure(puzzle_id)
	add_child(overlay)

func _show_functioning(text: String) -> void:
	var overlay := preload("res://scenes/ui/functioning.tscn").instantiate()
	overlay.configure("Fonctionnement", text)
	add_child(overlay)

func _back() -> void:
	if not Session.go_back().get("ok", false):
		Session.navigate("s02", false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		get_viewport().set_input_as_handled()
