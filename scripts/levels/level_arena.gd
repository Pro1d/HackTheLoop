extends LevelBase

const MAX_HEIGHT_OFFSET := 1.5

@onready var _camera_follower := %CameraFollower as CameraFollower
@onready var _x_height_default_1 := (%HeightDefaultMarker3D as Node3D).global_position.x
@onready var _x_height_max_1 := (%HeightMaxMarker3D as Node3D).global_position.x
@onready var _x_height_default_2 := (%HeightDefaultMarker3D2 as Node3D).global_position.x
@onready var _x_height_max_2 := (%HeightMaxMarker3D2 as Node3D).global_position.x


func _process(_delta: float) -> void:
	var x := _camera_follower.global_position.x
	var height_offset_factor_1 := remap(x, _x_height_default_1, _x_height_max_1, 0.0, 1.0)
	var height_offset_factor_2 := remap(x, _x_height_default_2, _x_height_max_2, 0.0, 1.0)
	var height_offset_factor := clampf(minf(height_offset_factor_1, height_offset_factor_2), 0, 1)
	_camera_follower.set_height_offset(height_offset_factor * MAX_HEIGHT_OFFSET)
