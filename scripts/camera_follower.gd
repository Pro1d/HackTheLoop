class_name CameraFollower
extends Node3D

@onready var _cam_focus_point := %CamFocusPoint as Node3D
@onready var _cam := %Camera3D as Camera3D
@onready var _default_camera_trasform := _cam.transform

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.frame_pre_draw.connect(func() -> void:
		if is_inside_tree():
			_cam_focus_point.global_position = global_position
			_cam_focus_point.global_position.y = maxf(global_position.y, 0)
	)

func set_height_offset(height_offset: float) -> void:
	_cam.transform = _default_camera_trasform.translated_local(Vector3.BACK * height_offset)
