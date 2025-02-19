extends Node

#const CursorArrowIcon := preload("res://assets/images/ui/cursor_arrow2.atlastex")
#const CursorIBeamIcon := preload("res://assets/images/ui/cursor_ibeam.atlastex")
#const CursorAimIcon := preload("res://assets/images/ui/cursor_aim1.atlastex")

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
