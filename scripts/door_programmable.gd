class_name DoorProgrammable
extends Node3D

@export var initially_opened := false

@onready var _program_wheel := %ProgramWheel as ProgramWheel
@onready var _animated_door := %AnimatedWireDoor as AnimatedWireDoor
@onready var _door_collision := %DoorCollisionShape3D as CollisionShape3D
@onready var _runner := %ProgramRunner as ProgramRunnerDoor

func _ready() -> void:
	_door_collision.disabled = initially_opened
	_animated_door.set_state(initially_opened, false)
	_program_wheel.program = _runner.program
	_runner.current_instruction_index_changed.connect(_program_wheel.set_current_instruction_index.bind(true))

func open() -> void:
	await _animated_door.set_state(true, true)
	_door_collision.disabled = true

func close() -> void:
	_door_collision.disabled = false
	await _animated_door.set_state(false, true)
