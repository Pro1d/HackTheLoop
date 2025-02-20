class_name Instruction
extends Resource

enum Type {
	RELOAD_AMMO, # | reload icon
	OPEN, # | open door / unlocked padlock icon
	CLOSE, # | open door / unlocked padlock icon
	WAIT_BUTTON, # | hourglass icon
	CHARGE, # + obj | arrow dash icon
	SCAN, # + obj | antenna or radar icon
	SHOOT, # + obj | aim ¤ icon
	EMIT, # | wifi icon
	SHOOT_AT, # + obj | aim ¤ icon
	WAIT, # | hourglass icon
	MOVE_UNTIL_COL, # + obj | arrow dash icon
	ROTATE_LEFT, # | <-, rotate icon
	ROTATE_RIGHT, # | ,-> rotate icon
	ROTATE_TOWARD, # + obj | rotate icon
	
	# no icon yet
	
	RESTORE_SHIELD, # + obj | shield+ icon
	KNOCK_BACK, # | fist icon
	MOVE_FOWARD, # | arrow up icon
	MOVE_TO, # + obj | arrow jump incon 
	SKIP_NEXT_IF, # + obj | ? <_|  question mark + next line icon
	TURN_ON, # + obj | ON
	TURN_OFF, # + obj | OFF
}

enum TargetType {
	NONE,
	BUTTON_GREEN,
	BUTTON_BLUE,
	BUTTON_PURPLE,
	BUTTON_YELLOW,
	PLAYER, # | paperboy icon
	PING, # | "you are here" icon
	RANDOM, # | dice icon
	
	# no icon yet
	
	ALLY, # nearest or ref | [°++°] robot head icon
	SELF, # | 
	FOREVER, # | inf / omega icon
}


@export var type : Type
@export var target_type : TargetType

func has_target() -> bool:
	return target_type != TargetType.NONE

func target_is_button() -> bool:
	return target_type in GroundButton.colors
