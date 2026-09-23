class_name SceneRouter
extends RefCounted

var routes: Dictionary
var stack: Array[String] = []
var current_view := ""

func _init(route_map: Dictionary) -> void:
	routes = route_map.duplicate(true)

func has_route(view_id: String) -> bool:
	return routes.has(view_id)

func path_for(view_id: String) -> String:
	return str(routes.get(view_id, ""))

func push(view_id: String) -> Dictionary:
	if not has_route(view_id):
		return {"ok": false, "error": "unknown_view"}
	if not current_view.is_empty() and current_view != view_id:
		stack.append(current_view)
	current_view = view_id
	return {"ok": true, "path": path_for(view_id)}

func replace(view_id: String) -> Dictionary:
	if not has_route(view_id):
		return {"ok": false, "error": "unknown_view"}
	current_view = view_id
	return {"ok": true, "path": path_for(view_id)}

func back() -> Dictionary:
	if stack.is_empty():
		return {"ok": false, "error": "empty_stack"}
	var target: String = stack.pop_back()
	current_view = target
	return {"ok": true, "path": path_for(target), "view_id": target}

func clear_to(view_id: String) -> Dictionary:
	stack.clear()
	return replace(view_id)
