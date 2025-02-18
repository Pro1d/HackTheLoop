extends Node3D

@onready var _player := %Player as Player
@onready var _program_editor := %ProgramEditor as ProgramEditor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player.program_wheel_interaction_requested.connect(_on_program_wheel_interaction_requested)
	_program_editor.close_requested.connect(_on_program_editor_close_requested)
	_program_editor.hide()
	
func _on_program_wheel_interaction_requested(pw: ProgramWheel) -> void:
	get_tree().paused = true
	_program_editor.set_program(pw.program, pw.current_instruction_index)
	_program_editor.show()
	
func _on_program_editor_close_requested() -> void:
	get_tree().paused = false
	_program_editor.hide()
