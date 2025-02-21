extends Node

#const CursorArrowIcon := preload("res://assets/images/ui/cursor_arrow2.atlastex")
#const CursorIBeamIcon := preload("res://assets/images/ui/cursor_ibeam.atlastex")
#const CursorAimIcon := preload("res://assets/images/ui/cursor_aim1.atlastex")

const DARK_INK := Color(0, 0.004, 0.337)
const LAYER_WORLD := 1 << 0
const LAYER_PLAYER := 1 << 1
const LAYER_ROBOT := 1 << 4

static var _intruction_to_string := {
	Instruction.Type.RELOAD_AMMO: "Reload ammo", # | reload icon
	Instruction.Type.OPEN: "Open door", # | open door / unlocked padlock icon
	Instruction.Type.CLOSE: "Close door", # | open door / unlocked padlock icon
	Instruction.Type.xxx_deprecated_waith_button_xxx: "???", # | hourglass icon
	Instruction.Type.CHARGE: "Charge attack", # + obj | arrow dash icon
	Instruction.Type.SCAN: "Detect", # + obj | antenna or radar icon
	Instruction.Type.SHOOT: "Shoot", # + obj | aim ¤ icon
	Instruction.Type.EMIT: "Send", # | wifi icon
	Instruction.Type.SHOOT_AT: "Shoot at", # + obj | aim ¤ icon
	Instruction.Type.WAIT: "Wait", # | hourglass icon
	Instruction.Type.MOVE_UNTIL_COL: "Move forward", # + obj | arrow dash icon
	Instruction.Type.ROTATE_LEFT: "Rotate left", # | <-, rotate icon
	Instruction.Type.ROTATE_RIGHT: "Rotate right", # | ,-> rotate icon
	Instruction.Type.ROTATE_TOWARD: "Rotate toward", # + obj | rotate icon
	Instruction.Type.TURN_AROUND: "Turn around", # + obj | rotate icon
}
static var _target_to_string := {
	Instruction.TargetType.NONE: "",
	Instruction.TargetType.BUTTON_GREEN: "Green button",
	Instruction.TargetType.BUTTON_BLUE: "Blue button",
	Instruction.TargetType.BUTTON_PURPLE: "Pink button",
	Instruction.TargetType.BUTTON_YELLOW: "Yellow button",
	Instruction.TargetType.PLAYER: "Paper Boy", # | paperboy icon
	Instruction.TargetType.PING: "Marker", # | "you are here" icon
	Instruction.TargetType.RANDOM: "Random", # | dice icon
	Instruction.TargetType.ROBOT: "Robot", # | robot head icon
}
func intruction_to_string(i: Instruction.Type) -> String:
	return _intruction_to_string[i]
func target_to_string(i: Instruction.TargetType) -> String:
	return _target_to_string[i]

func _enter_tree() -> void:
	for v: Instruction.Type in Instruction.Type.values():
		assert(v in _intruction_to_string)
	for v: Instruction.TargetType in Instruction.TargetType.values():
		assert(v in _target_to_string)
#	Input.set_custom_mouse_cursor(
#		CursorArrowIcon, Input.CURSOR_ARROW, Vector2(2, 2)
#	)
#	Input.set_custom_mouse_cursor(
#		CursorIBeamIcon, Input.CURSOR_IBEAM, Vector2(16, 16)
#	)
#	Input.set_custom_mouse_cursor(
#		CursorAimIcon, Input.CURSOR_CROSS, Vector2(16, 16)
#	)
	pass

	
func v3_to_v2(v: Vector3) -> Vector2:
	return Vector2(-v.z, -v.x)
func v2_to_v3(v: Vector2) -> Vector3:
	return Vector3(-v.y, 0, -v.x)

func angle_to_dir_index(a: float, dir_resolution: float) -> int:
	return posmod(roundi(a / dir_resolution), roundi(TAU / dir_resolution))
func dir_index_to_angle(i: int, dir_resolution: float) -> float:
	return i * dir_resolution
func round_angle(a: float, dir_resolution: float) -> float:
	return dir_index_to_angle(angle_to_dir_index(a, dir_resolution), dir_resolution)
