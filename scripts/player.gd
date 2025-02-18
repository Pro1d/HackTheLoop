class_name Player
extends CharacterBody3D

signal program_wheel_interaction_requested(program_wheel: ProgramWheel)

const MAX_SPEED = 3.0
const ACCEL = MAX_SPEED / 0.08

@export var handle_input := true

var current_interactable : Node = null
var target_orientation := 0.0

@onready var center_area := %CenterArea3D as Area3D

func _ready() -> void:
	#area.area_entered.connect(_on_area_entered_center)
	pass

func _input(event: InputEvent) -> void:
	if event.is_action("interact") and event.is_pressed():
		for area in center_area.get_overlapping_areas():
			var pw := ProgramWheel.find_parent_program_wheel(area)
			if pw != null:
				program_wheel_interaction_requested.emit(pw)
				current_interactable = pw
				
func _physics_process(delta: float) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("dodge_roll"):
		pass

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#var direction := (Vector3(input_dir.x, 0, input_dir.y)).normalized() # transform.basis *
	
	var current_h_speed := Vector2(velocity.x, velocity.z)
	var new_h_speed := current_h_speed
	
	if not input_dir.is_zero_approx():
		input_dir = input_dir.normalized()
		new_h_speed = current_h_speed.move_toward(input_dir * MAX_SPEED, ACCEL * delta)
		target_orientation = input_dir.angle_to(Vector2(0, -1))
	else:
		new_h_speed = current_h_speed.move_toward(Vector2.ZERO, ACCEL * delta)
	
	var current_v_speed := velocity.y
	var new_v_speed := current_v_speed
	if not is_on_floor():
		new_v_speed += get_gravity().y * delta
	else:
		new_v_speed = 0
		
	velocity = Vector3(new_h_speed.x, new_v_speed, new_h_speed.y)
	rotation.y = lerp_angle(rotation.y, target_orientation, delta ** 0.5)
	move_and_slide()

#func _on_area_entered_center(area: Area3D) -> void:
	#var program_wheel := ProgramWheel.find_parent_program_wheel(area)
	#if program_wheel != null:
		#
