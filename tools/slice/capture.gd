extends SceneTree
var scene: Control
var output: String="res://build/slice-captures"
func _init() -> void:call_deferred("run")
func run() -> void:
 DirAccess.make_dir_recursive_absolute(output)
 scene=load("res://scenes/slice/lantern.tscn").instantiate()
 scene.capture_mode=true
 scene.local_path="user://capture-never-saved.cfg"
 root.add_child(scene);current_scene=scene
 await create_timer(.7).timeout
 await shot("01-introduction")
 scene.begin()
 await create_timer(1.0).timeout
 await shot("02-gameplay")
 scene.inspect_mirror(0)
 await create_timer(.4).timeout
 await shot("03-inspection")
 scene._close_modal()
 scene.show_notebook()
 await create_timer(.4).timeout
 await shot("04-carnet")
 scene._close_modal()
 scene.turn_mirror(0);scene.turn_mirror(1);scene.turn_mirror(3)
 await create_timer(1.7).timeout
 await shot("05-light-arrives")
 await create_timer(1.8).timeout
 await shot("06-conclusion")
 scene.queue_free()
 await process_frame
 await process_frame
 quit()
func shot(name: String) -> void:
 await RenderingServer.frame_post_draw
 var pic:=root.get_texture().get_image()
 var error:=pic.save_png(output+"/"+name+".png")
 print("CAPTURE ",name," ",pic.get_size()," error=",error)
