class_name ProgramRunnerRobot
extends ProgramRunnerBase

@export var max_target_range := 8.0

func do_CHARGE(i: Instruction.TargetType) -> float:
	var loc := find_target_location(i, max_target_range)
	if loc.is_zero_approx():
		return ProgramRunnerBase.IGNORE_DELAY
	else:
		var mr := get_parent() as MobileRobot
		await mr.rotate_to(Vector2(-loc.z, -loc.x).angle())
		await mr.drive_until_hit(4.0)
		return 0.0

func do_MOVE_UNTIL_COL() -> float:
	var mr := get_parent() as MobileRobot
	await mr.drive_until_hit()
	return 0.0

func do_ROTATE_LEFT() -> float:
	var mr := get_parent() as MobileRobot
	await mr.rotate_left()
	return 0.0
	
func do_ROTATE_RIGHT() -> float:
	var mr := get_parent() as MobileRobot
	await mr.rotate_right()
	return 0.0
	
func do_ROTATE_TOWARD(i: Instruction.TargetType) -> float:
	var loc := find_target_location(i, max_target_range)
	if loc.is_zero_approx():
		return ProgramRunnerBase.IGNORE_DELAY
	else:
		var mr := get_parent() as MobileRobot
		await mr.rotate_to(Vector2(-loc.z, -loc.x).angle())
		return 0.0
