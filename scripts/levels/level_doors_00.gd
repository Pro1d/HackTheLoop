extends LevelBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	(%Label3D as Label3D).hide()
	(%GroundButton as GroundButton).pressed.connect((%Label3D as Label3D).show)
