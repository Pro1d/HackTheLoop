class_name GroundButton
extends Area3D

signal pressed()

const colors := {
	Instruction.TargetType.BUTTON_GREEN: Color(0, 0.619, 0.451),
	Instruction.TargetType.BUTTON_BLUE: Color(0, 0.447, 0.698),
	Instruction.TargetType.BUTTON_PURPLE: Color(0.8, 0.474, 0.655),
	Instruction.TargetType.BUTTON_YELLOW: Color(0.941, 0.894, 0.259),
}

@export var button_type := Instruction.TargetType.BUTTON_GREEN :
	set(bt):
		button_type = bt
		_update_color()

@onready var _move_on_pressed := %MoveOnPressed as Node3D
@onready var _area := self
@onready var _mat := (%MeshInstance3D as MeshInstance3D).get_surface_override_material(0) as StandardMaterial3D
@onready var _press_audio := %PressAudio3D as AudioStreamPlayer3D
@onready var _release_audio := %ReleaseAudio3D as AudioStreamPlayer3D

var _is_pressed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_area.body_entered.connect(_on_overlapping_bodies_changed.unbind(1))
	_area.body_exited.connect(_on_overlapping_bodies_changed.unbind(1))
	_update_color()

func _on_overlapping_bodies_changed() -> void:
	var is_pressed := not get_overlapping_bodies().is_empty()
	if _is_pressed != is_pressed:
		_is_pressed = is_pressed
		animate_pressed_state()
		if is_pressed:
			pressed.emit()

var _anim_tween : Tween
func animate_pressed_state() -> void:
	if _anim_tween != null:
		_anim_tween.kill()
	_anim_tween = create_tween()
	_anim_tween.tween_property(_move_on_pressed, "position:y", -0.03 if _is_pressed else 0.0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if _is_pressed:
		_press_audio.play()
	else:
		_release_audio.play()
	
func _update_color() -> void:
	if _mat == null: return
	_mat.albedo_color = colors[button_type]
	GroundButton._register_button(self)


#### Static GroundButton registration (global)

static var registered_buttons := {
	Instruction.TargetType.BUTTON_GREEN: null,
	Instruction.TargetType.BUTTON_BLUE: null,
	Instruction.TargetType.BUTTON_PURPLE: null,
	Instruction.TargetType.BUTTON_YELLOW: null,
}

static func _register_button(gb: GroundButton) -> void:
	registered_buttons[gb.button_type] = gb

static func find_registered_button(type: Instruction.TargetType) -> GroundButton:
	var obj : Variant = registered_buttons.get(type)
	if not is_instance_valid(obj):
		return null
	var gb := obj as GroundButton
	if gb != null and gb.is_inside_tree() and gb.button_type == type:
		return gb
	else:
		return null
