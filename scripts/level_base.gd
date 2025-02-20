class_name LevelBase
extends Node3D

signal level_completed
signal level_failed

enum State {
	INITIALIZING,
	PLAYING,
	ENDED
}

var _state := State.INITIALIZING

@onready var _end_level_area := %EndLevel as EndLevel
@onready var _player := %Player as Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player.program_wheel_interaction_requested.connect(_on_program_wheel_interaction_requested)
	_player.died.connect(_on_player_died)
	_end_level_area.body_entered.connect(_on_player_reach_end_level.unbind(1))
	#_player.process_mode = Node.PROCESS_MODE_DISABLED

func start() -> void:
	_state = State.PLAYING
	_player.unlock()
	#_player.process_mode = Node.PROCESS_MODE_INHERIT

func _on_program_wheel_interaction_requested(pw: ProgramWheel) -> void:
	match _state:
		State.PLAYING:
			Game.get_instance().on_program_wheel_interaction_requested(pw)
	
func _on_player_died() -> void:
	match _state:
		State.PLAYING:
			level_failed.emit()
			_state = State.ENDED

func _on_player_reach_end_level() -> void:
	match _state:
		State.PLAYING:
			level_completed.emit()
			_state = State.ENDED
