class_name Game
extends Node3D

enum State {
	INITIALIZED,
	STARTING_LEVEL,
	PLAYING_LEVEL,
	EDITING_PROGRAM,
	ENDING_LEVEL,
	#SCORE_SCREEN,
	CONFIRMING, # game is paused
}

var _state := State.INITIALIZED

@onready var _ui_program_editor := %ProgramEditor as ProgramEditor
@onready var _fade_rect := %FadeRect as FadeRect
@onready var _ui_confirm := %ConfirmDialog as ConfirmDialog

const _levels : Array[PackedScene] = [
	preload("res://scenes/levels/level_jail.tscn"),
	preload("res://scenes/levels/level_doors00.tscn"),
	preload("res://scenes/levels/level_plateform01.tscn"),
	preload("res://scenes/levels/level_doors01.tscn"),
	preload("res://scenes/levels/level_turrets01.tscn"),
	preload("res://scenes/levels/level_charge01.tscn"),
	preload("res://scenes/levels/level_turrets03.tscn"),
	preload("res://scenes/levels/level_plateform02.tscn"),
	preload("res://scenes/levels/level_doors02.tscn"),
	preload("res://scenes/levels/level_doors03.tscn"),
	preload("res://scenes/levels/level_turrets02.tscn"),
	preload("res://scenes/levels/level_arena.tscn"),
	preload("res://scenes/levels/score_screen.tscn"),
]
var _current_level_index := 0
var _current_level_scene : LevelBase

var skip_count := 0
var death_count := 0
var elapsed_time := 0.0

func _enter_tree() -> void:
	register_instance(self)

func _ready() -> void:
	_ui_program_editor.close_requested.connect(_on_program_editor_close_requested)
	_ui_program_editor.hide()
	
	_current_level_index = 0
	switch_level(true)
	MusicManager.start_game_music()

func _input(event: InputEvent) -> void:
	match _state:
		State.PLAYING_LEVEL:
			if event.is_action_pressed("reset"):
				_state = State.CONFIRMING
				get_tree().paused = true
				var reset := await _ui_confirm.open("Restart This Level?")
				_state = State.PLAYING_LEVEL
				get_tree().paused = false
				if reset:
					death_count += 1
					switch_level(false)
			elif event.is_action_pressed("back"):
				_state = State.CONFIRMING
				get_tree().paused = true
				var quit := await _ui_confirm.open("Quit To Menu?")
				_state = State.PLAYING_LEVEL
				get_tree().paused = false
				if quit:
					_current_level_index = _levels.size()
					switch_level(false)
			elif event.is_action_pressed("skip"):
				_state = State.CONFIRMING
				get_tree().paused = true
				var quit := await _ui_confirm.open("Skip This Level?") #, "Yes (achievement disabled)", "No")
				_state = State.PLAYING_LEVEL
				get_tree().paused = false
				if quit:
					_current_level_index += 1
					skip_count += 1
					switch_level(true)

func _physics_process(delta: float) -> void:
	match _state:
		State.PLAYING_LEVEL, State.EDITING_PROGRAM:
			elapsed_time += delta

func _load_level(index: int) -> void:
	if _current_level_scene != null:
		_current_level_scene.queue_free()
		await _current_level_scene.tree_exited
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
		death_count += 1
		switch_level(false)

func switch_level(success: bool) -> void:
	# Anim end level
	if _current_level_scene != null:
		_state = State.ENDING_LEVEL
		var t := create_tween()
		t.tween_callback(
			(($SuccessAudio if success else $FailAudio) as AudioStreamPlayer).play
		).set_delay(0.0 if success else 0.8)
		await t.finished
		t.kill()
		await _fade_rect.fade_out()
	
	# Load next level or go to menu
	if _current_level_index >= _levels.size():
		SceneManager.go_to_main_menu()
		return
	else:
		_load_level(_current_level_index)
	
	# Anim start level
	_state = State.STARTING_LEVEL
	await _fade_rect.fade_in()
	
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
		_ui_program_editor._program.emit_changed()

static var _instance : Game
static func register_instance(g: Game) -> void:
	_instance = g
static func get_instance() -> Game:
	return _instance if is_instance_valid(_instance) else null
