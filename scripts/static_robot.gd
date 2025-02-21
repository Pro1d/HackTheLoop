class_name StaticRobot
extends StaticBody3D

@export var program : Program
@export var rotor_speed := TAU / 3.0
@export var initial_angle_local_position := 0.0

var _tween : Tween

@onready var _program_wheel := %ProgramWheel as ProgramWheel
@onready var _runner := %ProgramRunner as ProgramRunnerRobot
@onready var _rotor_root := %Rotor as Node3D
@onready var _shot_marker := %ShootMarker as Node3D
@onready var _shoot_audio := %ShootAudio3D as AudioStreamPlayer3D

func _ready() -> void:
	_rotor_root.rotation.y = initial_angle_local_position
	
	program = program.duplicate_deep()
	_runner.program = program
	_program_wheel.program = program
	_runner.current_instruction_index_changed.connect(_program_wheel.set_current_instruction_index.bind(true))
	
	prints(self, _rotor_root.global_rotation.y)

func _current_angle() -> float:
	return _rotor_root.global_rotation.y

func _rotate_animation(target_angle: float) -> void:
	var current_angle := _current_angle()
	var angle_diff := angle_difference(current_angle, target_angle)
	var duration := absf(angle_diff) / rotor_speed
	
	_tween = create_tween()
	_tween.tween_property(_rotor_root, "global_rotation:y", current_angle + angle_diff, duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	await _tween.finished

func rotate_to(target_pos: Vector3) -> void:
	var target_pos_rel := Config.v3_to_v2(_rotor_root.get_parent_node_3d().to_local(to_global(target_pos)))
	var target_angle := target_pos_rel.angle()
	await _rotate_animation(target_angle)

func rotate_left() -> void:
	await _rotate_animation(_current_angle() + PI / 2)

func rotate_right() -> void:
	await _rotate_animation(_current_angle() - PI / 2)

func turn_around() -> void:
	await _rotate_animation(_current_angle() + PI)

func shoot_ahead() -> void:
	var projectile := Projectile.make(_shot_marker.global_transform, 12.0)
	get_tree().root.add_child(projectile)
	
	_shoot_audio.play()
	
	#await get_tree().create_timer(0.35, false).timeout

func scan_at(_target_pos: Vector3) -> void:
	pass
