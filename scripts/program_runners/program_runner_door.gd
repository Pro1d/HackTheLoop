class_name ProgramRunnerDoor
extends ProgramRunnerBase

@onready var door := get_parent() as DoorProgrammable

func do_OPEN(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	var done := await door.open()
	return 0.1 if done else ProgramRunnerBase.IGNORE_DELAY
	
func do_CLOSE(_i: Instruction.TargetType = Instruction.TargetType.NONE) -> float:
	#await get_tree().create_timer(0.2, false, true).timeout
	var done := await door.close()
	return 0.1 if done else ProgramRunnerBase.IGNORE_DELAY
