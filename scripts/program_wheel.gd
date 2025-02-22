class_name ProgramWheel
extends Node3D

const InstructionVisual3DPackedScene := preload("res://scenes/instruction_visual_3d.tscn")


@export var program : Program :
	set(p):
		if program != null and program.changed.is_connected(_update_program):
			program.changed.disconnect(_update_program)
		program = p
		program.changed.connect(_update_program)
		_update_program()
var current_instruction_index := 0

@onready var _spinning := %Spinning as Node3D
@onready var _instructions_root := %InstructionsRoot as Node3D
@onready var _ticking := %TickingAudio3D as AudioStreamPlayer3D
@onready var _tooltip_sprite := %ShortcutSprite3D as Sprite3D

var _spin_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_tooltip_visibility(false)
	_update_program()

func set_current_instruction_index(index: int, animate: bool) -> void:
	current_instruction_index = index
	_update_spin_position(animate)

func _update_spin_position(animate: bool) -> void:
	if program == null: return
	var current_angle := _spinning.rotation.x
	var icount := program.instruction_count() if program != null else 1
	var target_angle := -TAU / icount * current_instruction_index
	
	if _spin_tween != null:
		_spin_tween.kill()
	
	if not animate:
		_spinning.rotation.x = target_angle
		return
	
	_spin_tween = create_tween()
	target_angle = current_angle + angle_difference(current_angle, target_angle)
	if current_angle - target_angle < 1e-4:
		target_angle -= TAU
	_spin_tween.tween_property(_spinning, "rotation:x", target_angle, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	_spin_tween.parallel().tween_callback(_ticking.play).set_delay(0.3)

func _update_program() -> void:
	if _instructions_root == null or program == null: return
	
	var icount := program.instruction_count() if program != null else 0
	
	for i in range(icount):
		var iv : InstructionVisual3D
		if i >= _instructions_root.get_child_count():
			iv = InstructionVisual3DPackedScene.instantiate()
			_instructions_root.add_child(iv)
		else:
			iv = _instructions_root.get_child(i)
		iv.instruction = program.instructions[i]
		iv.rotation.x = TAU / icount * i
	
	for i in range(icount, _instructions_root.get_child_count()):
		_instructions_root.get_child(i).queue_free()
		
	_update_spin_position(false)

static func find_parent_program_wheel(area: Area3D) -> ProgramWheel:
	return area.get_parent() as ProgramWheel

func set_tooltip_visibility(v: bool) -> void:
	_tooltip_sprite.visible = v
