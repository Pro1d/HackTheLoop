class_name Program
extends Resource


@export var instructions : Array[Instruction]
#@export var loop : bool

func instruction_count() -> int:
	return instructions.size()

func duplicate_deep() -> Program:
	var p := Program.new()
	for instr in self.instructions:
		var i := Instruction.new()
		i.type = instr.type
		i.target_type = instr.target_type
		p.instructions.append(i)
	return p
