extends "res://src/ui/puzzle_screen_base.gd"

const PanoramaRules = preload("res://src/rules/panorama_rules.gd")
const P01PanoramaBoard = preload("res://src/ui/p01_panorama_board.gd")

var selected := -1

func _ready() -> void:
	Session.router.current_view = "s05"
	_rebuild()

func _rebuild() -> void:
	clear_page()
	var box := setup_page("Panorama", "Raccorder le panorama")
	box.add_child(UiFactory.make_label("Les marges sont fixes. À chaque couture, deux détails du paysage doivent se poursuivre.", Session.font_size_px(16)))
	var order: Array = Session.state.campaign["puzzles"]["p01"]["order"]
	var board := P01PanoramaBoard.new()
	board.configure(order, Session.state.puzzles_contract["p01"], selected)
	board.piece_pressed.connect(_select)
	box.add_child(board)
	add_common_tools(
		box,
		"p01",
		_verify,
		func(): ask_reset(_reset_confirmed),
		_undo,
		"Échangez les cinq lés. Les marges gauche et droite sont fixes. Chaque couture doit poursuivre deux détails."
	)

func _select(index: int) -> void:
	if selected < 0:
		selected = index
	elif selected == index:
		selected = -1
	else:
		history.append((Session.state.campaign["puzzles"]["p01"]["order"] as Array).duplicate())
		Session.state.swap_order("p01", selected, index)
		Session.save_now()
		selected = -1
	_rebuild()

func _undo() -> void:
	if history.is_empty():
		feedback = "Aucun geste à annuler."
	else:
		Session.state.campaign["puzzles"]["p01"]["order"] = history.pop_back()
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	selected = -1
	_rebuild()

func _reset_confirmed() -> void:
	Session.state.reset_unsolved_puzzle("p01")
	Session.save_now()
	history.clear()
	selected = -1
	feedback = ""
	_rebuild()

func _verify() -> void:
	var state: Array = Session.state.campaign["puzzles"]["p01"]["order"]
	var result := PanoramaRules.validate(state, Session.state.puzzles_contract["p01"])
	if result.get("valid", false):
		Session.state.resolve_puzzle("p01")
		Session.save_now()
		Session.navigate(Session.objective_view(), false)
	else:
		feedback = "Certaines lignes s'interrompent aux raccords."
		_rebuild()
