class_name InstructionVisual3D
extends Node3D

@export var instruction : Instruction :
	set(i):
		instruction = i
		_update()
		
@onready var _instruction_sprite := %InstructionSprite3D as Sprite3D
@onready var _target_sprite := %TargetSprite3D as Sprite3D
@onready var _bg_target_mesh := %TargetBGMeshInstance3D as MeshInstance3D
@onready var _left_pos_instruction_sprite := _instruction_sprite.position.x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instruction != null:
		_update()

func _update() -> void:
	if _instruction_sprite == null: return
	_instruction_sprite.frame = instruction.type
	_target_sprite.frame = instruction.target_type
	var has_target := instruction.has_target()
	_instruction_sprite.position.x = _left_pos_instruction_sprite if has_target else 0.0
	_target_sprite.visible = has_target
	_bg_target_mesh.visible = has_target
