@tool # Needed so it runs in editor.
extends EditorScenePostImport

var root : Node
var anim_player : AnimationPlayer
var out_path := ""

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene: Node) -> Node:
	# Change all node names to "modified_[oldnodename]"
	var dir := get_source_file().get_file().get_basename()
	out_path = "res://resources/models".path_join(dir)
	root = scene
	anim_player = root.find_child("AnimationPlayer")
	anim_player.owner = null
	root.remove_child(anim_player)
	_init_dir()
	_replace_materials(root)
	iterate(root, false)
	
	return scene # Remember to return the imported scene

func _init_dir() -> void:
	DirAccess.make_dir_absolute(out_path)
	#if DirAccess.dir_exists_absolute(out_path):
		##DirAccess.remove_absolute(out_path)
		#for file in DirAccess.get_files_at(out_path):
			#prints("delete", file, DirAccess.remove_absolute(out_path.path_join(file)))
	

# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func iterate(node: Node, recc: bool, depth: int = 0) -> void:
	prints("".lpad(depth), node, node.owner)
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null:
		ResourceSaver.save(mesh_instance.mesh, out_path.path_join(node.name+".res"))
		if not recc:
			return
	elif node.has_node("Skeleton3D"):
		var sk := node.find_child("Skeleton3D")
		var me := sk.get_child(0)
		me.owner = node
		sk.owner = node
		node.add_child(anim_player)
		anim_player.owner = node
		anim_player.root_node = "../.."
		var ps := PackedScene.new()
		ps.pack(node)
		ResourceSaver.save(ps, out_path.path_join(node.name+".res"))
		anim_player.owner = null
		node.remove_child(anim_player)
		if not recc:
			return
		
	#elif node is AnimationPlayer:
		#prints("--", (node as AnimationPlayer).root_node)
		#var ps := PackedScene.new()
		#ps.pack(node)
		#ResourceSaver.save(ps, out_path.path_join(node.name+".res"))
		#if not recc:
			#return
	
	#elif node is Skeleton3D:
		#var ps := PackedScene.new()
		#node.owner = node.get_parent()
		#root.remove_child(anim)
		#root
		#ps.pack(node.get_parent())
		#ResourceSaver.save(ps, out_path.path_join(node.get_parent().name+".skeleteon.scn"))
		#if not recc:
			#return
	
	if node != null:
		for child: Node in node.get_children():
			iterate(child, recc, depth+1)

func _replace_materials(node: Node) -> void:
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null:
		var m := mesh_instance.mesh as ArrayMesh
		for i in m.get_surface_count():
			var mat := m.surface_get_material(i)
			match mat.resource_name:
				"Cardboard":
					m.surface_set_material(i, preload("res://resources/materials/cardboard.tres"))
				"Fence":
					m.surface_set_material(i, preload("res://resources/materials/fence.tres"))
				"PlasticRed":
					pass #m.surface_set_material(i, preload("res://resources/materials/cardboard.tres"))
	if node != null:
		for child: Node in node.get_children():
			_replace_materials(child)
