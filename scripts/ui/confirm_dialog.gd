class_name ConfirmDialog
extends CenterContainer

signal answered(confirmed: bool)


@onready var _label := %Label as Label
@onready var _yes := %YesLabel as Label
@onready var _no := %NoLabel as Label

func _ready() -> void:
	hide()
	process_mode = PROCESS_MODE_DISABLED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yes"):
		answered.emit(true)
	elif event.is_action_pressed("no") or event.is_action_pressed("back"):
		answered.emit(false)

func open(text: String, yes: String = "Yes", no: String = "No") -> bool:
	_label.text = text
	_yes.text = "[Y] " + yes
	_no.text = "[N] " + no
	
	process_mode = PROCESS_MODE_INHERIT
	show()
	
	var confirmed : bool = await answered
	
	process_mode = PROCESS_MODE_DISABLED
	hide()
	return confirmed
