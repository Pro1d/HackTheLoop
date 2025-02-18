class_name AnimatedWireDoor
extends Node3D

@onready var _anim := $AnimationPlayer as AnimationPlayer

func set_state(open: bool, animate: bool) -> void:
	if animate:
		if open:
			_anim.play("wire-door")
		else:
			_anim.play_backwards("wire-door")
	else:
		if open:
			_anim.play("wire-door-opened")
		else:
			_anim.play_backwards("wire-door-closed")
	
	await _anim.animation_finished
