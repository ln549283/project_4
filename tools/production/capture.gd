extends SceneTree
## Render every campaign screen from isolated state; never touch a player's save.
var output := "res://build/production-captures"
func _init() -> void: call_deferred("run")
func run() -> void:
	if "--tall" in OS.get_cmdline_user_args():
		output += "/tall"
		root.size = Vector2i(540,1200)
	var session := root.get_node("Session")
	session.save_service = load("res://src/core/save_service.gd").new(session.state.puzzles_contract, "user://production-capture")
	session.campaign_started = false
	session.state.new_campaign("production-review")
	DirAccess.make_dir_recursive_absolute(output)
	for view in ["s00", "s01", "s03", "s02", "s05", "p08", "p09", "s06", "s07", "s08", "p10", "s09", "p11", "p12", "p17", "s10", "p16", "p14", "p15", "s11", "s12", "s13", "s14"]:
		session.router.current_view = view
		var scene: Control = load(session.ROUTES[view]).instantiate()
		root.add_child(scene)
		current_scene = scene
		await create_timer(0.8).timeout
		if scene.get_child_count() > 0 and scene.get_child(0) is MarginContainer:
			var margin: MarginContainer = scene.get_child(0)
			if margin.size.x > scene.size.x + 1.0:
				push_error("Horizontal overflow: " + view)
				quit(1)
				return
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png(output + "/" + view + ".png")
		if error != OK: quit(1); return
		root.remove_child(scene)
		scene.free()
		current_scene = null
		# Review fixture unlocks next screens; this is not a solver or playthrough.
		for id in session.STAGE_VIEWS:
			if session.STAGE_VIEWS[id] == view and id not in session.state.campaign.solved:
				session.state.campaign.solved.append(id)
	await process_frame
	quit()
