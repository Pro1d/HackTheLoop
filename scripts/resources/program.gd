class_name Program
extends Resource


@export var instructions : Array[Instruction]
#@export var loop : bool

func instruction_count() -> int:
	return instructions.size()
