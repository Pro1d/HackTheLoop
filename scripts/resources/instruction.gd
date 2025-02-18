class_name Instruction
extends Resource

enum Type {
	RELOAD_AMMO, # | reload icon
	OPEN, # | open door / unlocked padlock icon
	CLOSE, # | open door / unlocked padlock icon
	WAIT_BUTTON, # | hourglass icon
	SHOOT, # + obj | aim ¤ icon
	SHOOT_AT, # + obj | aim ¤ icon
	CHARGE, # + obj | arrow dash icon
	RESTORE_SHIELD, # + obj | shield+ icon
	EMIT, # | wifi icon
	KNOCK_BACK, # | fist icon
	MOVE_FOWARD, # | arrow up icon
	MOVE_TO, # + obj | arrow jump incon 
	SCAN, # + obj | antenna or radar icon
	WAIT, # | hourglass icon
	SKIP_NEXT_IF, # + obj | ? <_|  question mark + next line icon
	TURN_ON, # + obj | ON
	TURN_OFF, # + obj | OFF
	ROTATE_LEFT, # | <-, rotate icon
	ROTATE_RIGHT, # | ,-> rotate icon
	ROTATE_TOWARD, # + obj | rotate icon
}

enum TargetType {
	NONE,
	BUTTON_GREEN,
	BUTTON_BLUE,
	BUTTON_PURPLE,
	BUTTON_YELLOW,
	PLAYER, # [ paperboy icon
	ALLY, # nearest or ref | [°++°] robot head icon
	SELF, # | 
	RANDOM, # | dice icon
	BUTTON, # ref / text
}

@export var type : Type
@export var target_type : TargetType

func has_target() -> bool:
	return target_type != TargetType.NONE
