extends "res://src/ui/puzzle_screen_base.gd"

const SequenceRules = preload("res://src/rules/sequence_rules.gd")
const DONOR_NAMES := {"roof": "Toiture", "door": "Porte", "floor": "Plancher"}
const ACTION_NAMES := {
	"deliver": "Livrer les outils",
	"stairs": "Relever l'escalier",
	"floor": "Déposer le plancher",
	"brace": "Étayer le passage",
	"evacuate": "Faire passer le groupe",
	"release": "Détacher la barge",
}

var selected_action := ""

func _ready() -> void:
	Session.router.current_view = "s11"
	_rebuild()

func _rebuild() -> void:
	clear_page()
	var state: Dictionary = Session.state.campaign["puzzles"]["p07"]
	if not bool(state.get("part_a_solved", false)):
		_build_part_a()
	else:
		_build_part_b()

func _build_part_a() -> void:
	var box := setup_page("Ce qui portait — pièce", "Trouver ce qui pouvait franchir l'interruption")
	var contract: Dictionary = Session.state.puzzles_contract["p07"]
	box.add_child(UiFactory.make_label("L'interruption fait trois travées. F2 montre un tablier plat, deux unités de large et des attaches appariées.", Session.font_size_px(18)))
	for donor_id in ["roof", "door", "floor"]:
		var donor: Dictionary = contract["donors"][donor_id]
		var selected := Session.state.campaign["puzzles"]["p07"].get("donor") == donor_id
		var text := "%s%s — portée %d, largeur %d, %s, attaches %s" % [
			"[Sélectionnée] " if selected else "",
			DONOR_NAMES[donor_id],
			int(donor["span"]),
			int(donor["width"]),
			"plat" if bool(donor["flat"]) else "profil en V",
			"appariées" if bool(donor["paired_fasteners"]) else "simples",
		]
		box.add_child(UiFactory.make_button(text, _select_donor.bind(donor_id)))
	box.add_child(UiFactory.make_button("Essayer la pièce sélectionnée", _try_donor, true))
	box.add_child(UiFactory.make_button("Indice", func(): _show_hint("p07")))
	box.add_child(UiFactory.make_button("Carnet", func(): Session.open_notebook()))
	box.add_child(UiFactory.make_button("Retour", _back, true))
	if not feedback.is_empty():
		box.add_child(UiFactory.make_label(feedback, Session.font_size_px(16)))

func _select_donor(donor_id: String) -> void:
	Session.state.set_p07_donor(donor_id)
	Session.save_now()
	feedback = ""
	_rebuild()

func _try_donor() -> void:
	var donor: Variant = Session.state.campaign["puzzles"]["p07"].get("donor")
	if donor == null:
		feedback = "Sélectionnez d'abord une pièce."
		_rebuild()
		return
	var result := SequenceRules.validate_donor(str(donor), Session.state.puzzles_contract["p07"])
	if result.get("valid", false):
		Session.state.campaign["puzzles"]["p07"]["part_a_solved"] = true
		Session.state.queue_narrative("n08")
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	else:
		var violation: Dictionary = (result.get("violations", []) as Array)[0]
		match str(violation.get("rule_id", "")):
			"p07_wrong_span":
				feedback = "La portée ne correspond pas à l'interruption."
			"p07_too_narrow":
				feedback = "Le passage est trop étroit."
			"p07_profile_mismatch":
				feedback = "Le profil ne correspond pas à la photo."
			"p07_fasteners_mismatch":
				feedback = "Les attaches ne correspondent pas."
			_:
				feedback = "Cette pièce ne remplit pas la fonction observée."
	_rebuild()

func _build_part_b() -> void:
	var box := setup_page("Ce qui portait — frise", "Rejouer le passage")
	var contract: Dictionary = Session.state.puzzles_contract["p07"]
	var slots: Array = Session.state.campaign["puzzles"]["p07"]["slots"]
	box.add_child(UiFactory.make_label("Six phases observées, niveaux 0 à 5. Déposer les cartes ne fait pas avancer le temps.", Session.font_size_px(18)))
	box.add_child(UiFactory.make_label(_rules_text(), Session.font_size_px(16)))
	if not selected_action.is_empty():
		box.add_child(UiFactory.make_label("Sélection : " + ACTION_NAMES[selected_action], Session.font_size_px(16)))

	box.add_child(UiFactory.make_label("Cartes disponibles", Session.font_size_px(18)))
	for raw_action: Variant in contract["actions"]:
		var action := str(raw_action)
		if action not in slots:
			box.add_child(UiFactory.make_button(ACTION_NAMES[action], _select_action.bind(action)))

	box.add_child(UiFactory.make_label("Frise", Session.font_size_px(18)))
	for phase in range(6):
		var occupant: Variant = slots[phase]
		var text := "Niveau %d — %s" % [phase, "vide" if occupant == null else ACTION_NAMES[str(occupant)]]
		box.add_child(UiFactory.make_button(text, _phase_pressed.bind(phase)))
	if not selected_action.is_empty() and selected_action in slots:
		box.add_child(UiFactory.make_button("Retourner la carte au bac", _return_selected))

	add_common_tools(
		box,
		"p07",
		_replay,
		func(): ask_reset(_reset_confirmed),
		_undo,
		"Placez les six opérations dans les six phases en respectant leurs fenêtres et leurs dépendances. La crue ne progresse pas pendant votre réflexion.",
		"Rejouer"
	)

func _rules_text() -> String:
	return "0 seulement : livrer les outils.\nEscalier : au plus tard 1.\nPlancher : à partir de 2, après les outils.\nÉtais : à partir de 3, après le plancher.\nPassage : avant 5, escalier relevé et plancher étayé.\nDétacher la barge : après le passage."

func _select_action(action: String) -> void:
	selected_action = action
	feedback = ""
	_rebuild()

func _phase_pressed(phase: int) -> void:
	var slots: Array = Session.state.campaign["puzzles"]["p07"]["slots"]
	if selected_action.is_empty():
		if slots[phase] != null:
			selected_action = str(slots[phase])
			_rebuild()
		return
	history.append(_snapshot())
	var result := Session.state.place_p07_action(selected_action, phase)
	if result.get("ok", false):
		Session.save_now()
		feedback = ""
	else:
		history.pop_back()
		feedback = "Cette carte ne peut pas être placée."
	selected_action = ""
	_rebuild()

func _return_selected() -> void:
	if selected_action.is_empty():
		return
	history.append(_snapshot())
	var result := Session.state.place_p07_action(selected_action, -1)
	if result.get("ok", false):
		Session.save_now()
	else:
		history.pop_back()
	selected_action = ""
	_rebuild()

func _snapshot() -> Dictionary:
	return (Session.state.campaign["puzzles"]["p07"] as Dictionary).duplicate(true)

func _undo() -> void:
	if history.is_empty():
		feedback = "Aucun geste à annuler."
	else:
		Session.state.campaign["puzzles"]["p07"] = history.pop_back()
		Session.state.dirty = true
		Session.save_now()
		feedback = ""
	selected_action = ""
	_rebuild()

func _reset_confirmed() -> void:
	Session.state.reset_unsolved_puzzle("p07")
	Session.save_now()
	history.clear()
	selected_action = ""
	feedback = ""
	_rebuild()

func _replay() -> void:
	var state: Dictionary = Session.state.campaign["puzzles"]["p07"]
	var donor := str(state.get("donor", ""))
	var sequence: Array = state["slots"]
	var result := SequenceRules.validate(donor, sequence, Session.state.puzzles_contract["p07"])
	if result.get("valid", false):
		Session.state.resolve_puzzle("p07")
		Session.state.queue_narrative("n09")
		Session.save_now()
		Session.navigate("s02", false)
		return
	var violations: Array = result.get("violations", [])
	if violations.is_empty():
		feedback = "Cette reconstitution ne permet pas encore le passage complet."
		_rebuild()
		return
	var violation: Dictionary = violations[0]
	var rule_id := str(violation.get("rule_id", ""))
	var params: Dictionary = violation.get("params", {})
	if rule_id == "p07_window_violation":
		feedback = _window_message(str(params.get("action", "")))
	elif rule_id == "p07_before_violation":
		feedback = "Un support est utilisé avant d'être prêt."
	elif rule_id in ["p07_incomplete_sequence", "p07_missing_action"]:
		feedback = "Cette reconstitution ne permet pas encore le passage complet."
	else:
		feedback = "La reconstitution rencontre une contradiction."
	_rebuild()

func _window_message(action: String) -> String:
	match action:
		"deliver":
			return "La rampe de l'atelier est déjà noyée."
		"stairs":
			return "L'axe de l'escalier n'est plus accessible."
		"floor":
			return "La barge est encore trop basse."
		"brace":
			return "Les étais n'ont pas encore leur appui."
		"evacuate":
			return "Le groupe passe trop tard."
		"release":
			return "La barge doit rester jusqu'au dernier passage."
		_:
			return "Une opération est placée hors de sa fenêtre."
