extends Node3D


@onready var _player := %Player as Player
@onready var _play_area := %PlayEndLevel as EndLevel
@onready var _fade_rect := %FadeRect as FadeRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_play_area.body_entered.connect(func(b: Node3D) -> void:
		if b == _player:
			_start_game()
	)
	
	MusicManager.start_menu_music()
	await _fade_rect.fade_in()
	_player.unlock()

func _start_game() -> void:
	_fade_rect.fade_out()
	SceneManager.go_to_game.call_deferred()
