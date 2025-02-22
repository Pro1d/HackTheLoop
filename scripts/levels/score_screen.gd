extends LevelBase


@onready var _game_stats_label := %GameStatsLabel3D as Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_display_game_stats()
	MusicManager.start_menu_music()

func _display_game_stats() -> void:
	var death := Game.get_instance().death_count
	var skip := Game.get_instance().skip_count
	var time := Game.get_instance().elapsed_time
	_game_stats_label.text += "\n"
	_game_stats_label.text += "\nCompleted in %s" % [format_time(time)]
	_game_stats_label.text += "\n%d Paper Boys crushed" % [death]
	if skip > 0:
		_game_stats_label.text += "\n%d level%s skipped" % [skip, "s" if skip >= 2 else ""]
		#_game_stats_label.text += "\n- achievement disabled -"

func format_time(time: float) -> String:
	var hours := int(time / (60 * 60))
	var minutes := int(time / 60) % 60
	var sec := int(time) % 60
	var cs := int(time * 100) % 100
	return (
		"%d:%02d:%02d" % [hours, minutes, sec]
		if hours > 0 else
		"%d:%02d.%02d" % [minutes, sec, cs]
	)
