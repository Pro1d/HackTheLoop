class_name Door
extends Node3D

@export var initially_opened := false

var opened := false

@onready var _animated_door := %AnimatedWireDoor as AnimatedWireDoor
@onready var _door_collision := %DoorCollisionShape3D as CollisionShape3D
@onready var _open_audio := %OpenAudio3D as AudioStreamPlayer3D
@onready var _close_audio := %CloseAudio3D as AudioStreamPlayer3D

func _ready() -> void:
	_door_collision.disabled = initially_opened
	_animated_door.set_state(initially_opened, false)
	opened = initially_opened

func open() -> bool:
	if not opened:
		_open_audio.play()
		await _animated_door.set_state(true, true)
		_door_collision.set_disabled.call_deferred(true)
		opened = true
		return true
	else:
		return false

func close() -> bool:
	if opened:
		_close_audio.play()
		opened = false
		_door_collision.set_disabled.call_deferred(false)
		await _animated_door.set_state(false, true)
		return true
	else:
		return false
