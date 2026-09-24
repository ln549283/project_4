extends SceneTree
const Loader=preload("res://src/core/contract_loader.gd")
const Rules=preload("res://src/rules/expansion_rules.gd")
const State=preload("res://src/core/game_state.gd")
const Save=preload("res://src/core/save_service.gd")
var failures: Array[String]=[]
func _init() -> void:
	var loaded: Dictionary=Loader.load_and_validate()
	check(loaded.ok,"contracts")
	if not loaded.ok:
		print(loaded.errors)
		quit(1)
		return
	var p: Dictionary=loaded.data.puzzles
	for i in range(8,18):
		var id: String="p%02d"%i
		var c: Dictionary=p[id]
		check(Rules.valid_state(c,c.initial),id+" initial is valid")
		check(not Rules.validate(c,c.initial).valid,id+" initial not solved")
		check(Rules.validate(c,c.solution).valid,id+" solution")
		check(not Rules.valid_state(c,{}),id+" empty state rejected")
		if c.kind in ["slide","pour","ferry"]:
			var state: Dictionary=c.initial.duplicate(true)
			for move: Array in c.solution_moves:
				var action: Dictionary={"crew":move} if c.kind=="ferry" else {"a":int(move[0]),"b":int(move[1])}
				var result: Dictionary=Rules.act(c,state,action)
				check(result.get("ok",false),id+" legal witness move")
				if result.get("ok",false): state=result.state
			check(Rules.validate(c,state).valid,id+" solved by legal actions")
	# Invalid moves preserve input; no magic teleport or clipping.
	var slide: Dictionary=p.p09.initial.duplicate(true)
	var before: Dictionary=slide.duplicate(true)
	check(not Rules.act(p.p09,slide,{"a":0,"b":-1}).ok,"drawer cannot leave left edge")
	check(slide==before,"rejected action atomic")
	check(not Rules.act(p.p16,p.p16.initial,{"crew":[2]}).ok,"unmanned boat rejected")
	check(not Rules.act(p.p16,p.p16.initial,{"crew":[0,2,3]}).ok,"overload rejected")
	check(not Rules.act(p.p11,p.p11.initial,{"a":0,"b":1}).ok,"fixed rope anchor")
	# Counts checked against independent Python enumeration.
	for id in ["p13","p14","p17"]:
		var count := 0
		var possibilities := 64 if id=="p13" else (256 if id=="p14" else 125)
		var radix := 2 if id=="p13" else (4 if id=="p14" else 5)
		for n in range(possibilities):
			var digits: Array=[]
			var remaining: int=n
			for _i in range(6 if id=="p13" else (4 if id=="p14" else 3)):
				digits.append(remaining%radix)
				remaining=remaining/radix
			var s: Dictionary={"turns":digits}
			if id=="p17": s={"offsets":[0]+digits}
			if Rules.validate(p[id],s).valid: count+=1
		check(count==1,id+" exactly one accepted state")
	# All phases survive save/load, with only genuinely solved additions marked solved.
	var game: Node=State.new()
	game.configure(loaded.data)
	game.new_campaign("expanded-test")
	var service=Save.new(p,"user://expanded-test-"+str(Time.get_ticks_usec()))
	for id: String in p.campaign_order:
		if id=="ending": continue
		check(game.can_enter(id),id+" reachable")
		for required: String in loaded.data.evidence.required_by_stage.get(id,[]):
			check(required in game.available_evidence(),id+" evidence "+required)
		if int(id.substr(1))>=8:
			check(not game.resolve_puzzle(id).get("ok",false),id+" cannot resolve unsolved")
			game.campaign.puzzles[id]=p[id].solution.duplicate(true)
		check(game.resolve_puzzle(id).get("ok",false),id+" resolve")
		var result: Dictionary=service.save_campaign(game.campaign)
		check(result.get("ok",false),id+" save")
		var loaded_save: Dictionary=service.load_campaign()
		check(loaded_save.get("status")=="ok",id+" reload")
		if loaded_save.get("status")=="ok":game.campaign=loaded_save.snapshot
	check(game.can_enter("ending"),"end reachable")
	# Migration of a fully solved v1.1 campaign preserves achievements without granting additions.
	var legacy: Dictionary=game.campaign.duplicate(true)
	legacy.content_version="1.1"
	legacy.solved=["p00","p01","p02","p03","p04","p05","p06","p07"]
	legacy.narrative={"active_scene":null,"segment":0,"pending":[],"acknowledged":["n11"]}
	legacy.completed=true
	for i in range(8,18):
		legacy.puzzles.erase("p%02d"%i)
		legacy.hints.erase("p%02d"%i)
	var old_service=Save.new(p,"user://legacy-test-"+str(Time.get_ticks_usec()))
	check(old_service.write_envelope_for_test("a",legacy),"write legacy fixture")
	var migrated: Dictionary=old_service.load_campaign()
	check(migrated.get("status")=="ok","legacy loads")
	if migrated.get("status")=="ok":
		check(migrated.snapshot.solved==legacy.solved,"legacy solved preserved")
		check(migrated.snapshot.puzzles.p08==p.p08.initial,"added puzzle not fabricated as solved")
		check(migrated.snapshot.completed,"completed old game preserved")
		check(old_service.save_campaign(migrated.snapshot).get("ok",false),"migrated saves")
		check(FileAccess.file_exists(old_service.root_path+"/campaign_a.json.v11_backup"),"legacy raw backup")
		check(old_service.load_campaign().get("status")=="ok","migrated reloads")
	game.free()
	for failure in failures: push_error(failure)
	print("EXPANSION RULES / CAMPAIGN / MIGRATION: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
func check(condition: bool,message: String) -> void:
	if not condition:failures.append(message)
