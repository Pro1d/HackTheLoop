class_name ProgramRunnerBase
extends Node

# does not emit for the 1st instruction (always index 0)
signal current_instruction_index_changed(instr_index: int)

@export var program : Program
var current_instruction_index := 0
var current_instruction : Instruction :
	get(): return program.instructions[current_instruction_index] 
var running := false

var _timer := Timer.new()

func _ready() -> void:
	_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	add_child(_timer)
	
	_run.call_deferred()

func _run() -> void:
	assert(program != null)
	running = true
	
	while running:
		var func_name := "do_" + (Instruction.Type.find_key(current_instruction.type) as String)
		if not has_method(func_name):
			func_name = "_do_default"
		
		var delay := 0.0
		if current_instruction.has_target():
			delay = await call(func_name, current_instruction.target_type)
		else:
			delay = await call(func_name)
		
		if delay > 0.0:
			_timer.start(delay)
			await _timer.timeout
		else:
			await get_tree().physics_frame
		
		current_instruction_index = (current_instruction_index + 1) % program.instruction_count()
		current_instruction_index_changed.emit(current_instruction_index)

func _do_default(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	return 1.0

func do_WAIT_BUTTON(i: Instruction.TargetType) -> float:
	var ground_button := GroundButton.find_registered_button(i)
	if ground_button != null:
		await ground_button.pressed
		return 0.0
	else:
		return 2.0
