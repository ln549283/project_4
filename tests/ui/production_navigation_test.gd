extends SceneTree
func _init() -> void: call_deferred("run")
func run() -> void:
	var session := root.get_node("Session")
	session.save_service = load("res://src/core/save_service.gd").new(session.state.puzzles_contract, "user://production-nav-test")
	session.state.new_campaign("production-navigation")
	session.campaign_started = true
	session.state.campaign.solved = ["p00"]
	session.state.campaign.puzzles.p01.order = session.state.puzzles_contract.p01.solution.duplicate()
	var scene: Control = load("res://scenes/puzzles/p01.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	scene._verify()
	await process_frame
	await process_frame
	var ok: bool = session.router.current_view == "p08"
	if not ok: push_error("P01 must continue to P08, not locked P02")
	print("PRODUCTION NAVIGATION: ", "PASS" if ok else "FAIL")
	if current_scene != null: current_scene.queue_free()
	await process_frame
	quit(0 if ok else 1)
