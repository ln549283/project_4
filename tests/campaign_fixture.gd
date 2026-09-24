extends RefCounted
## Test-only helpers. They do not change runtime gates or fabricate migration flags.
static func solve_added(state: Node, ids: Array) -> void:
	for id: String in ids:
		state.campaign.puzzles[id]=state.puzzles_contract[id].solution.duplicate(true)
		assert(state.resolve_puzzle(id).get("ok",false),"Fixture prerequisite: "+id)
