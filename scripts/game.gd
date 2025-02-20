class_name Game
extends Node3D

enum State {
	INITIALIZED,
	STARTING_LEVEL,
	PLAYING_LEVEL,
	EDITING_PROGRAM,
	ENDING_LEVEL,
	#SCORE_SCREEN,
	CONFIRMING_RESET,
}

var _state := State.INITIALIZED

@onready var _ui_program_editor := %ProgramEditor as ProgramEditor
@onready var _fade_rect := %FadeRect as ColorRect
@onready var _ui_confirm_reset := %ConfirmReset as Control

const _levels : Array[PackedScene] = [
	preload("res://scenes/levels/level_jail.tscn"),
	preload("res://scenes/levels/level_arena.tscn"),
	#preload("res://scenes/level_base.tscn"),
]
var _current_level_index := 0
var _current_level_scene : LevelBase

func _enter_tree() -> void:
	register_instance(self)

func _ready() -> void:
	_ui_program_editor.close_requested.connect(_on_program_editor_close_requested)
	_ui_program_editor.hide()
	_ui_confirm_reset.hide()
	
	_current_level_index = 0
	switch_level(true)
	MusicManager.start_game_music()

func _input(event: InputEvent) -> void:
	match _state:
		State.PLAYING_LEVEL:
			if event.is_action_pressed("reset"):
				_state = State.CONFIRMING_RESET
				_ui_confirm_reset.show()
		State.CONFIRMING_RESET:
			if event.is_action_pressed("yes"):
				_ui_confirm_reset.hide()
				switch_level(false)
			elif event.is_action_pressed("no") or event.is_action_pressed("back"):
				_ui_confirm_reset.hide()
				_state = State.PLAYING_LEVEL

func _load_level(index: int) -> void:
	if _current_level_scene != null:
		_current_level_scene.queue_free()
		_current_level_scene = null
	_current_level_scene = _levels[index].instantiate()
	_current_level_scene.level_completed.connect(_on_level_completed)
	_current_level_scene.level_failed.connect(_on_level_failed)
	add_child(_current_level_scene)

func _on_level_completed() -> void:
	if _state == State.PLAYING_LEVEL:
		_current_level_index += 1
		switch_level(true)

func _on_level_failed() -> void:
	if _state == State.PLAYING_LEVEL:
		switch_level(false)

func switch_level(success: bool) -> void:
	var t : Tween
	
	_fade_rect.show()
	if _current_level_scene != null:
		_state = State.ENDING_LEVEL
		t = create_tween()
		t.tween_property(_fade_rect, "modulate:a", 1.0, 2.0).from(0.0)
		await t.finished
		if success:
			($SuccessAudio as AudioStreamPlayer).play()
		else:
			($FailAudio as AudioStreamPlayer).play()
	
	_load_level(_current_level_index)
	
	_state = State.STARTING_LEVEL
	t = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 0.0, 2.0).from(1.0)
	await t.finished
	_fade_rect.hide()
	
	_state = State.PLAYING_LEVEL
	_current_level_scene.start()

func on_program_wheel_interaction_requested(pw: ProgramWheel) -> void:
	if _state == State.PLAYING_LEVEL:
		_state = State.EDITING_PROGRAM
		get_tree().paused = true
		_ui_program_editor.set_program(pw.program, pw.current_instruction_index)
		_ui_program_editor.show()
	
func _on_program_editor_close_requested() -> void:
	if _state == State.EDITING_PROGRAM:
		_state = State.PLAYING_LEVEL
		get_tree().paused = false
		_ui_program_editor.hide()

static var _instance : Game
static func register_instance(g: Game) -> void:
	_instance = g
static func get_instance() -> Game:
	return _instance
