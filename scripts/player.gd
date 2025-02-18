class_name Player
extends CharacterBody3D

signal program_wheel_interaction_requested(program_wheel: ProgramWheel)

const MAX_SPEED = 3.0
const ACCEL = MAX_SPEED / 0.08

@export var handle_input := true

var current_interactable : Node = null

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
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not input_dir.is_zero_approx():
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, ACCEL * delta)
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	if not is_on_floor():
		velocity -= get_gravity() * delta
	move_and_slide()

#func _on_area_entered_center(area: Area3D) -> void:
	#var program_wheel := ProgramWheel.find_parent_program_wheel(area)
	#if program_wheel != null:
		#
