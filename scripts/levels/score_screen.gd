extends LevelBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	MusicManager.start_menu_music()
