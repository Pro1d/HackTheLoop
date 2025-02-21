class_name ProgramRunnerBase
extends Node

const IGNORE_DELAY := 0.5 # when action could not be performed
const MIN_DELAY := 0.5

# does not emit for the 1st instruction (always index 0)
signal current_instruction_index_changed(instr_index: int)

@export var max_target_range := 6.0
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
		
		delay = await call(func_name, current_instruction.target_type)
		
		delay += _timer.time_left
		
		if delay > 0.0:
			_timer.stop()
			_timer.start(delay)
			await _timer.timeout
		
		current_instruction_index = (current_instruction_index + 1) % program.instruction_count()
		current_instruction_index_changed.emit(current_instruction_index)

func _do_default(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	return 1.0

func do_WAIT(i: Instruction.TargetType) -> float:
	if await wait_target(i, max_target_range):
		return 0.0
	else:
		return IGNORE_DELAY

func wait_target(i: Instruction.TargetType, max_range: float) -> bool:
	while true:
		var self_loc := (get_parent() as Node3D).global_position
		match i:
			Instruction.TargetType.BUTTON_GREEN, \
			Instruction.TargetType.BUTTON_PURPLE, \
			Instruction.TargetType.BUTTON_YELLOW, \
			Instruction.TargetType.BUTTON_BLUE:
				var gb := GroundButton.find_registered_button(i)
				if gb != null:
					await gb.pressed
					return true
				else:
					return false
			Instruction.TargetType.PLAYER:
				var p := Player.find_registered_player()
				if p != null and p.is_alive() and p.global_position.distance_to(self_loc) < max_range:
					return true
				# else: retry in next frame
			Instruction.TargetType.PING:
				return false # TODO
			Instruction.TargetType.RANDOM:
				await get_tree().create_timer(randf_range(1.0, 4.0), false, true).timeout
				return true
			Instruction.TargetType.ROBOT:
				var robot := _find_nearest_body(max_range, Config.LAYER_ROBOT) as MobileRobot
				if robot != null:
					return true
				# else: retry in next frame
			Instruction.TargetType.NONE:
				await get_tree().create_timer(0.5, false, true).timeout
				return true
			_:
				return false
		
		await get_tree().physics_frame
	return false

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
		Instruction.TargetType.ROBOT:
			var robot := _find_nearest_body(max_range, Config.LAYER_ROBOT) as MobileRobot
			if robot != null:
				node_3d = robot
	
	if node_3d != null:
		var relative := node_3d.global_position - self_loc
		if relative.length_squared() < max_range * max_range:
			return relative
	return Vector3.ZERO

static var _cache_params := PhysicsShapeQueryParameters3D.new()
func _find_nearest_body(radius: float, layer_mask: int) -> PhysicsBody3D:
	var parent := get_parent() as Node3D
	var params := ProgramRunnerBase._cache_params
	
	params.transform = Transform3D(Basis(), parent.global_position + Vector3(0, 0.75, 0))
	params.collision_mask = layer_mask
	
	if params.shape == null:
		params.shape = CylinderShape3D.new()

	var cylinder := params.shape as CylinderShape3D
	cylinder.height = 1.2
	cylinder.radius = radius
	
	var state := parent.get_world_3d().direct_space_state
	var dmin := INF
	var body_min : PhysicsBody3D
	for dict in state.intersect_shape(params, 32):
		var b := dict["collider"] as PhysicsBody3D
		if b != null and b != parent:
			var d := b.global_position.distance_to(parent.global_position)
			if d < dmin:
				dmin = d
				body_min = b

	return body_min
