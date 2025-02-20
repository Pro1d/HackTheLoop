extends Node

#const CursorArrowIcon := preload("res://assets/images/ui/cursor_arrow2.atlastex")
#const CursorIBeamIcon := preload("res://assets/images/ui/cursor_ibeam.atlastex")
#const CursorAimIcon := preload("res://assets/images/ui/cursor_aim1.atlastex")

const DARK_INK := Color(0, 0.004, 0.337)
const LAYER_WORLD := 1 << 0
const LAYER_PLAYER := 1 << 1
const LAYER_ROBOT := 1 << 4

func _enter_tree() -> void:
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
