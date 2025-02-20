class_name DoorProgrammable
extends Door

@export var program : Program

@onready var _program_wheel := %ProgramWheel as ProgramWheel
@onready var _runner := %ProgramRunner as ProgramRunnerDoor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_runner.program = program
	_program_wheel.program = program
	_runner.current_instruction_index_changed.connect(_program_wheel.set_current_instruction_index.bind(true))
