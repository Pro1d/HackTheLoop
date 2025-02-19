class_name Player
extends CharacterBody3D

signal program_wheel_interaction_requested(program_wheel: ProgramWheel)
signal died()

enum State {
	LOCKED,
	WALKING,
	ROLLING,
	DEAD,
	#INTERACTING
}

const MAX_SPEED := 3.0
const ROLL_SPEED := MAX_SPEED * 2.0
const ACCEL := MAX_SPEED / 0.08

@export var handle_input := true

var current_interactable : Node = null
var _current_dir := Vector2(1, 0)
var _state := State.WALKING
var _rolling_timer := Timer.new()

@onready var _visual := %AnimatedPaperBoy as Node3D
@onready var _anim_player := %AnimatedPaperBoy/AnimationPlayer as AnimationPlayer
#@onready var _visual_mat := ((%AnimatedPaperBoy/Skeleton3D/PaperBoy as MeshInstance3D).mesh as ArrayMesh).surface_get_material(0) as StandardMaterial3D
@onready var center_area := %CenterArea3D as Area3D
@onready var _roll_audio := $RollAudio3D as AudioStreamPlayer3D
@onready var _walk_audio := $WalkAudio3D as AudioStreamPlayer3D
@onready var _die_audio := $DieAudio3D as AudioStreamPlayer3D

func _ready() -> void:
	_state = State.LOCKED
	_rolling_timer.wait_time = 0.4
	_rolling_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_rolling_timer.one_shot = true
	_rolling_timer.timeout.connect(_end_rolling)
	add_child(_rolling_timer)
	_anim_player.play(&"paper-boy-default")
	
	Player._register(self)

func unlock() -> void:
	if _state == State.LOCKED:
		_state = State.WALKING

func _input(event: InputEvent) -> void:
	if _state == State.WALKING:
		if event.is_action("interact") and event.is_pressed():
			for area in center_area.get_overlapping_areas():
				var pw := ProgramWheel.find_parent_program_wheel(area)
				if pw != null:
					program_wheel_interaction_requested.emit(pw)
					current_interactable = pw

func _physics_process(delta: float) -> void:
	var input_dir : Vector2
	var current_h_speed := Vector2(-velocity.z, -velocity.x)
	var new_h_speed := current_h_speed
	var on_floor := is_on_floor()
	
	match _state:
		State.WALKING:
			input_dir = Input.get_vector("move_down", "move_up", "move_right", "move_left")
			if not input_dir.is_zero_approx():
				input_dir = input_dir.normalized()
				_current_dir = input_dir
				new_h_speed = current_h_speed.move_toward(input_dir * MAX_SPEED, ACCEL * delta)
				if not _anim_player.is_playing():
					_anim_player.play(&"paper-boy-walk", -1, 0.3)
					_walk_audio.play()
			else:
				new_h_speed = current_h_speed.move_toward(Vector2.ZERO, ACCEL * delta)
				if not _anim_player.is_playing():
					_anim_player.play(&"paper-boy-default")
			
			if on_floor and Input.is_action_just_pressed("dodge_roll"):
				_start_rolling()
				new_h_speed = _current_dir * ROLL_SPEED
		State.ROLLING:
			new_h_speed = _current_dir * ROLL_SPEED
		State.DEAD:
			return
	
	var current_v_speed := velocity.y
	var new_v_speed := current_v_speed
	if not on_floor:
		new_v_speed += get_gravity().y * delta
	else:
		new_v_speed = 0
		
	velocity = Vector3(-new_h_speed.y, new_v_speed, -new_h_speed.x)
	rotation.y = lerp_angle(rotation.y, _current_dir.angle(), delta ** 0.5)
	
	move_and_slide()

func _start_rolling() -> void:
	_state = State.ROLLING
	var anim_rool := &"paper-boy-roll"
	_anim_player.play(
		anim_rool,
		-1,
		_anim_player.get_animation(anim_rool).length / _rolling_timer.wait_time
	)
	_anim_player.queue(&"paper-boy-default")
	_roll_audio.play()
	_rolling_timer.start()

func _end_rolling() -> void:
	assert(_state == State.ROLLING)
	_state = State.WALKING # FIXME
	_rolling_timer.stop()

func is_alive() -> bool:
	return _state != State.DEAD

func kill(hit_direction: Vector2 = Vector2.ZERO) -> void:
	match _state:
		State.ROLLING:
			_end_rolling()
		State.DEAD:
			return
	
	_state = State.DEAD
	_anim_player.stop(true) # keep state
	var axis : Vector3
	var angle : float
	if not hit_direction.is_zero_approx():
		var axis_2d := hit_direction.rotated(PI/2)
		axis = Vector3(-axis_2d.y, 0, -axis_2d.x).normalized()
		angle = deg_to_rad(30)
	else:
		axis = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
		angle = deg_to_rad(10)
	(_visual.get_parent() as Node3D).global_rotate(axis, angle)
	#_visual.global_scale(Vector3(1.0, 0.1, 1.0))
	#_visual_mat.normal_scale = 6.0
	(%CollisionShape3D as CollisionShape3D).disabled = true
	_die_audio.play()
	
	var tween := create_tween()
	tween.tween_property(_visual.get_parent().get_parent(), "scale:y", 0.2, 0.2) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.1)
	var t1 := (_visual.get_parent() as Node3D).transform
	(_visual.get_parent() as Node3D).global_rotate(axis, angle)
	var t2 := (_visual.get_parent() as Node3D).transform
	(_visual.get_parent() as Node3D).transform = t1
	tween.parallel().tween_property(_visual.get_parent(), "transform", t2, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	# TODO animate particles
	
	died.emit()


#### Static GroundButton registration (global)

static var _registered_player : Player

static func _register(p: Player) -> void:
	_registered_player = p

static func find_registered_player() -> Player:
	var p := _registered_player
	if p != null and is_instance_valid(p) and p.is_inside_tree():
		return p
	else:
		return null
