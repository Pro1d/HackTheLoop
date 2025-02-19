class_name ProgramRunnerDoor
extends ProgramRunnerBase

@onready var door := get_parent() as DoorProgrammable

func do_OPEN() -> float:
	var done := await door.open()
	return 0.5 if done else ProgramRunnerBase.IGNORE_DELAY
	
func do_CLOSE() -> float:
	#await get_tree().create_timer(0.2, false, true).timeout
	var done := await door.close()
	return 0.5 if done else ProgramRunnerBase.IGNORE_DELAY
