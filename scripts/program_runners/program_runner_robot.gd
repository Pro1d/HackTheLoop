class_name ProgramRunnerRobot
extends ProgramRunnerBase


func do_CHARGE(i: Instruction.TargetType) -> float:
	var loc := find_target_location(i, max_target_range)
	var mr := get_parent() as MobileRobot
	if loc.is_zero_approx() or mr == null:
		return ProgramRunnerBase.IGNORE_DELAY
	else:
		await mr.rotate_to(loc)
		await mr.drive_until_hit(5.0)
		return 0.0

func do_MOVE_UNTIL_COL(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	var mr := get_parent() as MobileRobot
	if  mr == null:
		return ProgramRunnerBase.IGNORE_DELAY
	else:
		await mr.drive_until_hit()
		return 0.0

func do_ROTATE_LEFT(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	var r := get_parent()
	if r.has_method("rotate_left"):
		await r.call("rotate_left")
		return 0.0
	else:
		return ProgramRunnerBase.IGNORE_DELAY
	
func do_ROTATE_RIGHT(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	var r := get_parent()
	if r.has_method("rotate_right"):
		await r.call("rotate_right")
		return 0.0
	else:
		return ProgramRunnerBase.IGNORE_DELAY
	
func do_ROTATE_TOWARD(i: Instruction.TargetType) -> float:
	var loc := find_target_location(i, max_target_range)
	var r := get_parent()
	if loc.is_zero_approx() or not r.has_method("rotate_to"):
		return ProgramRunnerBase.IGNORE_DELAY
	else:
		await r.call("rotate_to", loc)
		return 0.0

func do_TURN_AROUND(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	var r := get_parent()
	if r.has_method("turn_around"):
		await r.call("turn_around")
		return 0.0
	else:
		return ProgramRunnerBase.IGNORE_DELAY

func do_SHOOT(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	var r := get_parent()
	if not r.has_method("shoot_ahead"):
		return ProgramRunnerBase.IGNORE_DELAY
	else:
		await r.call("shoot_ahead")
		return 0.0

func do_SHOOT_AT(i: Instruction.TargetType) -> float:
	var loc := find_target_location(i, max_target_range)
	var r := get_parent()
	
	var ignore := true
	if loc.is_zero_approx() or not r.has_method("rotate_to"):
		pass
	else:
		ignore = false
		await r.call("rotate_to", loc)
	
	if not r.has_method("shoot_ahead"):
		pass
	else:
		await r.call("shoot_ahead")
		ignore = false
	
	return ProgramRunnerBase.IGNORE_DELAY if ignore else 0.0

func do_SCAN(i: Instruction.TargetType) -> float:
	var loc := find_target_location(i, max_target_range)
	var r := get_parent()
	
	var ignore := true

	if loc.is_zero_approx() or not r.has_method("rotate_to"):
		pass
	else:
		ignore = false
		await r.call("rotate_to", loc)
	
	if loc.is_zero_approx() or not r.has_method("ping_at"):
		pass
	else:
		await r.call("ping_at", loc)
		ignore = false
	
	return ProgramRunnerBase.IGNORE_DELAY if ignore else 0.0
