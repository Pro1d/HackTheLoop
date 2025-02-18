class_name ProgramRunnerDoor
extends ProgramRunnerBase

@onready var door := get_parent() as DoorProgrammable

func do_OPEN() -> float:
	await door.open()
	return 1.0
	
func do_CLOSE() -> float:
	await door.close()
	return 1.0
