class_name ProgramRunnerBase
extends Node

const IGNORE_DELAY := 0.5 # when action could not be performed
const MIN_DELAY := 0.25

# does not emit for the 1st instruction (always index 0)
signal current_instruction_index_changed(instr_index: int)

@export var program : Program
var current_instruction_index := 0
var current_instruction : Instruction :
	get(): return program.instructions[current_instruction_index] 
var running := false

var _timer := Timer.new()

func _ready() -> void:
	_timer.one_shot = true
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
		
		_timer.start(MIN_DELAY)
		
		if current_instruction.has_target():
			delay = await call(func_name, current_instruction.target_type)
		else:
			delay = await call(func_name)
		
		delay += _timer.time_left
		
		if delay > 0.0:
			_timer.stop()
			_timer.start(delay)
			await _timer.timeout
		
		current_instruction_index = (current_instruction_index + 1) % program.instruction_count()
		current_instruction_index_changed.emit(current_instruction_index)

func _do_default(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	return 1.0

func do_WAIT_BUTTON(i: Instruction.TargetType) -> float:
	var ground_button := GroundButton.find_registered_button(i)
	if ground_button != null:
		await ground_button.pressed
		return 0.25
	else:
		return IGNORE_DELAY

func find_target_location(i: Instruction.TargetType, max_range: float) -> Vector3:
	var self_loc := (get_parent() as Node3D).global_position
	var node_3d : Node3D
	match i:
		Instruction.TargetType.BUTTON_GREEN, \
		Instruction.TargetType.BUTTON_PURPLE, \
		Instruction.TargetType.BUTTON_YELLOW, \
		Instruction.TargetType.BUTTON_BLUE:
			node_3d = GroundButton.find_registered_button(i)
		Instruction.TargetType.PLAYER:
			var p := Player.find_registered_player()
			if p != null and p.is_alive():
				node_3d = p
		Instruction.TargetType.PING:
			pass
		Instruction.TargetType.RANDOM:
			return Vector3(
				randf_range(1.0, max_range), self_loc.y, 0
			).rotated(Vector3.UP, randf() * TAU)
	
	if node_3d != null:
		var relative := node_3d.global_position - self_loc
		if relative.length_squared() < max_range * max_range:
			return relative
	return Vector3.ZERO
