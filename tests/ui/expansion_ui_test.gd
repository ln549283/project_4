extends SceneTree
var failures: Array[String]=[]
var session: Node
func _init() -> void:
	call_deferred("run")
func run() -> void:
	session=root.get_node("Session")
	session.initialize()
	session.save_service=load("res://src/core/save_service.gd").new(session.state.puzzles_contract,"user://ui-expansion-"+str(Time.get_ticks_usec()))
	session.campaign_started=true
	session.state.new_campaign("ui-expanded")
	for id: String in session.state.puzzles_contract.campaign_order:
		if id=="ending":continue
		if int(id.substr(1))<8:
			session.state.resolve_puzzle(id)
			continue
		session.state.campaign.narrative={"active_scene":null,"segment":0,"pending":[],"acknowledged":[]}
		var scene: Control=load("res://scenes/puzzles/"+id+".tscn").instantiate()
		root.add_child(scene)
		current_scene=scene
		await process_frame
		await process_frame
		var board: Node=scene.find_child("PuzzleBoard",true,false)
		check(board!=null,id+" board instantiates")
		check(scene.has_method("_apply"),id+" controller compiles")
		var p: Dictionary=session.state.puzzles_contract[id]
		var initial: Dictionary=session.state.campaign.puzzles[id].duplicate(true)
		# Exercise actual controller gesture -> save -> undo -> reset path.
		var actions := {"p08":{"a":0,"b":1},"p09":{"a":int(p.solution_moves[0][0]),"b":int(p.solution_moves[0][1])} if id=="p09" else {},"p10":{"a":0,"placement":[0,0,0]},"p11":{"a":1,"b":2},"p12":{"a":0,"b":1},"p13":{"a":0},"p14":{"a":0},"p15":{"a":3},"p16":{"crew":[0,1]},"p17":{"a":1,"b":1}}
		scene._apply(actions[id])
		check(session.state.campaign.puzzles[id]!=initial,id+" gesture mutates")
		scene._undo()
		check(session.state.campaign.puzzles[id]==initial,id+" undo restores")
		scene._reset()
		check(session.state.campaign.puzzles[id]==initial,id+" reset restores")
		session.state.campaign.puzzles[id]=p.solution.duplicate(true)
		check(session.state.resolve_puzzle(id).get("ok",false),id+" resolves")
		scene._rebuild()
		var solved: Dictionary=session.state.campaign.puzzles[id].duplicate(true)
		scene._apply(actions[id])
		check(solved==session.state.campaign.puzzles[id],id+" solved read only")
		root.remove_child(scene)
		scene.free()
		current_scene=null
	for failure in failures:push_error(failure)
	print("EXPANSION UI: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
func check(value: bool,message: String) -> void:
	if not value:failures.append(message)
