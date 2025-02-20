class_name MobileRobot
extends CharacterBody3D

signal obstacle_hit(body: PhysicsBody3D, hit_velocity: Vector2)
#signal dir_changed
signal command_finished

enum Command { NONE, ROTATE, MOVE_AND_COLLIDE }

const dir_count := 4
const dir_resolution := TAU / dir_count

@export var program : Program
@export var max_speed := 1.2
@export var accel := 1.2 / 0.5
@export var rotation_speed := (PI / 2) / 1.0
@export var stop_on_player := true

var _command := Command.NONE
var _target_dir := Vector2(1, 0)
var _speed_factor := 1.0

@onready var _program_wheel := %ProgramWheel as ProgramWheel
@onready var _runner := %ProgramRunner as ProgramRunnerRobot
@onready var _hit_audio := %HitAudio3D as AudioStreamPlayer3D
@onready var _rotate_audio := %RotateAudio3D as AudioStreamPlayer3D
@onready var _move_audio :=  %MoveAudio3D as AudioStreamPlayer3D
@onready var _default_move_volume := _move_audio.volume_db

func _ready() -> void:
	_runner.program = program
	_program_wheel.program = program
	_runner.current_instruction_index_changed.connect(_program_wheel.set_current_instruction_index.bind(true))
	if not stop_on_player:
		collision_mask &= ~Config.LAYER_PLAYER
	obstacle_hit.connect(_on_obstacle_hit)

func _angle_to_dir(a: float) -> int:
	return Config.angle_to_dir_index(a, dir_resolution)

func _physics_process(delta: float) -> void:
	var h_speed := Vector2(-velocity.z, -velocity.x)
	
	match _command:
		Command.ROTATE:
			var angle_diff := angle_difference(rotation.y, _target_dir.angle())
			if abs(angle_diff) < deg_to_rad(1):
				_command = Command.NONE
				command_finished.emit()
			else:
				var angle_low_speed := deg_to_rad(15)
				var rs := rotation_speed * clampf(minf(absf(angle_diff), angle_low_speed) / angle_low_speed, 0.4, 1)
				rotation.y += clampf(angle_diff, -rs * delta, rs * delta)
		Command.MOVE_AND_COLLIDE:
			h_speed = h_speed.move_toward(_target_dir * max_speed * _speed_factor, accel * delta * _speed_factor)
		_:
			h_speed = h_speed.move_toward(Vector2.ZERO, accel * delta)
	
	# Gravity
	var current_v_speed := velocity.y
	var new_v_speed := current_v_speed
	if not is_on_floor():
		new_v_speed += get_gravity().y * delta
	else:
		new_v_speed = 0
		
	velocity = Vector3(-h_speed.y, new_v_speed, -h_speed.x)
	move_and_slide()
	
	if _command == Command.MOVE_AND_COLLIDE:
		var new_h_speed := Vector2(-velocity.z, -velocity.x)
		if h_speed.length() > 0.01 * delta and new_h_speed.length() < 0.01 * delta and is_on_wall():
			var col := get_last_slide_collision()
			var body := col.get_collider()
			obstacle_hit.emit(body as PhysicsBody3D, h_speed)
			
			_hit_audio.play()
			_move_audio.stop()
			
			_command = Command.NONE
			command_finished.emit()

func _on_obstacle_hit(body: PhysicsBody3D, hit_speed: Vector2) -> void:
	if body is Player and _speed_factor > 1.0 and hit_speed.length() / max_speed > (_speed_factor - 0.1):
		prints("player hit by mobile robot")
		(body as Player).kill(hit_speed)

func rotate_left() -> void:
	if _command != Command.NONE:
		await command_finished
	
	var current_dir := _angle_to_dir(rotation.y)
	var target_angle := ((current_dir + 1) % dir_count) * dir_resolution
	_target_dir = Vector2(1, 0).rotated(target_angle)
	
	_command = Command.ROTATE
	_rotate_audio.play()
	await command_finished

func rotate_right() -> void:
	if _command != Command.NONE:
		await command_finished
	
	var current_dir := _angle_to_dir(rotation.y)
	var target_angle := ((current_dir - 1 + dir_count) % dir_count) * dir_resolution
	_target_dir = Vector2(1, 0).rotated(target_angle)
	
	_command = Command.ROTATE
	_rotate_audio.play()
	await command_finished
	
func rotate_to(target_pos: Vector3) -> void:
	if _command != Command.NONE:
		await command_finished
	
	_target_dir = Config.v3_to_v2(target_pos)
	
	_command = Command.ROTATE
	_rotate_audio.play()
	await command_finished
	
func drive_until_hit(speed_factor: float = 1.0) -> void:
	if _command != Command.NONE:
		await command_finished
		
	_speed_factor = speed_factor
	_command = Command.MOVE_AND_COLLIDE
	_move_audio.play()
	_move_audio.volume_db = _default_move_volume + linear_to_db(speed_factor)
	await command_finished
	_speed_factor = 1.0

func kill() -> void:
	queue_free()
	# animate particles ?
