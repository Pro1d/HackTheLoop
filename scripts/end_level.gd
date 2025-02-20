@tool
class_name EndLevel
extends Area3D

@export var size := Vector3(1.0, 1.51, 1.0):
	set(s):
		size = s
		_update_size()

@onready var _mesh := %MeshInstance3D as MeshInstance3D
@onready var _box := _mesh.mesh as BoxMesh
@onready var _mat := _mesh.get_surface_override_material(0) as ShaderMaterial
#@onready var _collision := %CollisionShape3D as CollisionShape3D
#@onready var _shape := _collision.shape as BoxShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_size()

func _update_size() -> void:
	if _mesh == null: return
	const margin := 0.2
	_box.size = size + Vector3.ONE * (margin * 2)
	_mesh.position.y = size.y / 2
	#_shape.size = Vector3(size.x, 1, size.z)
	_mat.set_shader_parameter("offset", Vector3(0, 0, (size.z / 2 - .1)))
	_mat.set_shader_parameter("max_depth", 1.0)
