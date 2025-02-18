class_name Game
extends Node3D

@onready var _program_editor := %ProgramEditor as ProgramEditor
@onready var _fade_rect := %FadeRect as ColorRect

const _levels : Array[PackedScene] = [
	preload("res://scenes/level_base.tscn"),
	preload("res://scenes/level_base.tscn"),
]
var _current_level_index := 0
var _current_level_scene : LevelBase

func _enter_tree() -> void:
	register_instance(self)

func _ready() -> void:
	_program_editor.close_requested.connect(_on_program_editor_close_requested)
	_program_editor.hide()
	
	_current_level_index = 0
	switch_level()

func _load_level(index: int) -> void:
	if _current_level_scene != null:
		_current_level_scene.queue_free()
		_current_level_scene = null
	_current_level_scene = _levels[index].instantiate()
	_current_level_scene.level_completed.connect(_on_level_completed)
	_current_level_scene.level_failed.connect(_on_level_failed)
	add_child(_current_level_scene)

func _on_level_completed() -> void:
	prints("_on_level_completed")
	_current_level_index += 1
	switch_level()

func _on_level_failed() -> void:
	prints("_on_level_failed")
	switch_level()

func switch_level() -> void:
	var t := create_tween()
	_fade_rect.show()
	t.tween_property(_fade_rect, "modulate:a", 1.0, 2.0).from(0.0)
	await t.finished
	_load_level(_current_level_index)
	t = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 0.0, 2.0).from(1.0)
	await t.finished
	_fade_rect.hide()
	_current_level_scene.start()

func on_program_wheel_interaction_requested(pw: ProgramWheel) -> void:
	get_tree().paused = true
	_program_editor.set_program(pw.program, pw.current_instruction_index)
	_program_editor.show()
	
func _on_program_editor_close_requested() -> void:
	get_tree().paused = false
	_program_editor.hide()

static var _instance : Game
static func register_instance(g: Game) -> void:
	_instance = g
static func get_instance() -> Game:
	return _instance
