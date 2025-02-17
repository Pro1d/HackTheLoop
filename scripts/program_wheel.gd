extends Node3D

const InstructionVisual3DPackedScene := preload("res://scenes/instruction_visual_3d.tscn")


@export var program : Program :
	set(p):
		program = p
		_update_program()
@export var current_instruction_index := 0

var current_instruction : Instruction :
	get(): return program.instructions[current_instruction_index]

#@onready var _area := %Area3D as Area3D
@onready var _spinning := %Spinning as Node3D
@onready var _instructions_root := %InstructionsRoot as Node3D

var spin_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_program()
	#while true:
		#await get_tree().create_timer(2.0).timeout
		#spin_once()

func spin_once() -> void:
	current_instruction_index = (current_instruction_index + 1) % program.instruction_count()
	_update_spin_position(true)

func _update_spin_position(animate: bool) -> void:
	var current_angle := _spinning.rotation.x
	var icount := program.instruction_count() if program != null else 1
	var target_angle := -TAU / icount * current_instruction_index
	
	if spin_tween != null:
		spin_tween.kill()
	
	if not animate:
		_spinning.rotation.x = target_angle
		return
	
	spin_tween = create_tween()
	target_angle = current_angle + angle_difference(current_angle, target_angle)
	if is_equal_approx(target_angle, current_angle):
		target_angle += TAU
	spin_tween.tween_property(_spinning, "rotation:x", target_angle, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	
func _update_program() -> void:
	if _instructions_root == null: return
	
	var icount := program.instruction_count() if program != null else 0
	
	for i in range(icount):
		var iv : InstructionVisual3D
		if i >= _instructions_root.get_child_count():
			iv = InstructionVisual3DPackedScene.instantiate()
			_instructions_root.add_child(iv)
		else:
			iv = _instructions_root.get_child(i)
		iv.instruction = program.instructions[i]
		iv.rotation.x = -TAU / icount * i
	
	for i in range(icount, _instructions_root.get_child_count()):
		_instructions_root.get_child(i).queue_free()
		
	_update_spin_position(false)
