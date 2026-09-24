extends SceneTree
var failed: Array[String]=[]
func _init() -> void:
	call_deferred("run")
func run() -> void:
	visit("res://src")
	for path in failed: push_error("Cannot instantiate script: "+path)
	print("ALL RUNTIME SCRIPTS: ","PASS" if failed.is_empty() else "FAIL")
	quit(0 if failed.is_empty() else 1)
func visit(path: String) -> void:
	var dir:=DirAccess.open(path)
	for child in dir.get_directories():visit(path+"/"+child)
	for file in dir.get_files():
		if file.ends_with(".gd"):
			var script: Script=load(path+"/"+file)
			if script==null or not script.can_instantiate():failed.append(path+"/"+file)
