class_name ProgramEditor
extends Control

signal close_requested()

const InstructionUIPackedScene := preload("res://scenes/ui/instruction_ui.tscn")

enum State {
	INITIALIZING,
	NAVIGATING,
	SWAPPING,
}

var _program : Program = Program.new()
var _source_program : Program
var _is_edited := false

var _current_instruction_index := 0
var _nav_index := 0 : set=set_nav_index
var _displayed_index := float(_nav_index)
var _swap_target_only := false
var _swap_index := -1
var _state := State.INITIALIZING

var _instruction_ui_list : Array[InstructionUI]

@onready var _instr_container := %InstructionsContainer as VLoopContainer
@onready var _desc_label_instr := %DescriptionLabel as Label
@onready var _desc_label_target := %DescriptionLabel2 as Label
@onready var _ro_label := %ROLabel as Label
@onready var _swap_audio := %SwapAudio as AudioStreamPlayer
@onready var _select_audio := %SelectAudio as AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var p := Program.new()
	#p.instructions.append(Instruction.new())
	#p.instructions.append(Instruction.new())
	#p.instructions.append(Instruction.new())
	#p.instructions.append(Instruction.new())
	##p.instructions.append(Instruction.new())
	#p.instructions[0].target_type = Instruction.TargetType.PLAYER
	#p.instructions[1].type = Instruction.Type.SHOOT
	#p.instructions[3].target_type = Instruction.TargetType.PLAYER
	#p.instructions[2].target_type = Instruction.TargetType.PLAYER
	#set_program(p, 0)
	set_program(_program, 0)

func _reset_program() -> void:
	_swap_audio.play()
	for i in range(_program.instruction_count()):
		_program.instructions[i] = _source_program.instructions[i].duplicate(true)
	_is_edited = false
	_update_program()
	_state = State.NAVIGATING

func set_program(p: Program, current_instruction_index: int) -> void:
	_state = State.INITIALIZING
	_source_program = p.duplicate_deep()
	_program = p
	_is_edited = false
	_current_instruction_index = current_instruction_index
	_update_program()
	_state = State.NAVIGATING

func _update_program() -> void:
	_swap_target_only = false
	_swap_index = -1
	for ui in _instruction_ui_list:
		ui.queue_free()
	_instruction_ui_list.clear()
	#var instructions_with_target := {}
	for i in range(_program.instruction_count()):
		var ui := InstructionUIPackedScene.instantiate() as InstructionUI
		#if _program.instructions[i].has_target():
			#instructions_with_target[_program.instructions[i].type] = null
		ui.instruction = _program.instructions[i]
		ui.is_current = (_current_instruction_index == i)
		_instruction_ui_list.append(ui)
		_instr_container.add_child(ui)
	set_nav_index(_current_instruction_index)
	#(%SwapModeLabel as Control).visible = (instructions_with_target.size() > 1)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action("reset"):
			match _state:
				State.NAVIGATING, State.SWAPPING:
					if _is_edited:
						_reset_program()
		elif event.is_action("move_down") or event.is_action("move_up"):
			var dir := -1 if event.is_action("move_up") else 1
			match _state:
				State.NAVIGATING:
					set_nav_index(posmod(_nav_index + dir, _program.instruction_count()))
				State.SWAPPING:
					set_nav_index(
						_next_swappable_instr_index(dir)
						if not _swap_target_only
						else _next_swappable_target_index(dir)
					)
		elif event.is_action("move_left") or event.is_action("move_right"):
			match _state:
				State.NAVIGATING:
					if _program.instructions[_nav_index].has_target():
						_swap_target_only = event.is_action("move_right")
						_update_highlight()
		elif event.is_action("interact"):
			match _state:
				State.NAVIGATING:
					if _nav_index != _current_instruction_index:
						_swap_index = _nav_index
						_update_highlight()
						_select_audio.play()
						_state = State.SWAPPING
				State.SWAPPING:
					# if _nav_index != _current_instruction_index: # not possible with swapping navigation mode
					if _nav_index != _swap_index:
						_do_swap()
						_is_edited = true
						_swap_index = -1
						_update_highlight()
						_update_description()
						_swap_audio.play()
					else:
						_swap_index = -1
						_update_highlight()
						_select_audio.play()
					_state = State.NAVIGATING
		elif event.is_action("reset"):
			pass # TODO
		elif event.is_action("back"):
			match _state:
				State.NAVIGATING:
					close_requested.emit()
				State.SWAPPING:
					_swap_index = -1
					_state = State.NAVIGATING
					_update_highlight()

func _do_swap() -> void:
	assert(_state == State.SWAPPING)
	if _swap_target_only:
		var tts := _program.instructions[_swap_index].target_type
		var ttn := _program.instructions[_nav_index].target_type
		_program.instructions[_swap_index].target_type = ttn
		_program.instructions[_nav_index].target_type = tts
	else:
		var instr_s := _program.instructions[_swap_index]
		var instr_n := _program.instructions[_nav_index]
		_program.instructions[_swap_index] = instr_n
		_program.instructions[_nav_index] = instr_s
	_instruction_ui_list[_swap_index].instruction = _program.instructions[_swap_index]
	_instruction_ui_list[_nav_index].instruction = _program.instructions[_nav_index]

func _update_highlight() -> void:
	for i in range(_program.instruction_count()):
		if i == _swap_index:
			_instruction_ui_list[i].highlight_type = (
				InstructionUI.HighlightType.SELECT_INSTR
				if not _swap_target_only
				else InstructionUI.HighlightType.SELECT_TARGET
			)
		elif i == _nav_index:
			_instruction_ui_list[i].highlight_type = (
				InstructionUI.HighlightType.FOCUS_INSTR
				if not _swap_target_only
				else InstructionUI.HighlightType.FOCUS_TARGET
			)
		else:
			_instruction_ui_list[i].highlight_type = InstructionUI.HighlightType.NONE

var _tween_scroll : Tween
func _update_scroll_index(animate: bool) -> void:
	if _tween_scroll != null:
		_tween_scroll.kill()
	
	if not animate:
		_set_displayed_scroll_index(float(_nav_index))
	else:
		var findex_max := float(_program.instruction_count())
		var current_findex := _displayed_index
		var target_findex := float(_nav_index)
		var diff_findex := wrapf(target_findex - current_findex, -findex_max / 2, findex_max / 2)
		
		_tween_scroll = create_tween()
		_tween_scroll.tween_method(
			_set_displayed_scroll_index, current_findex, current_findex + diff_findex, 0.6
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)


func _set_displayed_scroll_index(findex: float) -> void:
	_displayed_index = findex
	_instr_container.center_on_index(findex)

func _next_swappable_instr_index(dir: int = 1) -> int:
	for i in range(_program.instruction_count()):
		var j := posmod(_nav_index + (i + 1) * dir, _program.instruction_count())
		if j != _current_instruction_index:
			return j
	return _nav_index

func _next_swappable_target_index(dir: int = 1) -> int:
	for i in range(_program.instruction_count()):
		var j := posmod(_nav_index + (i + 1) * dir, _program.instruction_count())
		if j != _current_instruction_index and _program.instructions[j].has_target():
			return j
	return _nav_index

func set_nav_index(ni: int) -> void:
	_nav_index = ni
	if _swap_target_only and not _program.instructions[_nav_index].has_target():
		_swap_target_only = false
	_update_scroll_index(_state != State.INITIALIZING)
	_update_highlight()
	_update_description()

func _update_description() -> void:
	if _program.instruction_count() == 0:
		return
	
	# Update description
	var instr := _program.instructions[_nav_index]
	
	var idesc := "\"%s\"" % [Config.intruction_to_string(instr.type)]
	var tdesc := "-"
	if instr.has_target():
		tdesc = "\"%s\"" % [Config.target_to_string(instr.target_type)]
		
	_desc_label_instr.text = "Action: %s" % [idesc]
	_desc_label_target.text = "Target: %s" % [tdesc]
	
	var is_current := (_current_instruction_index == _nav_index)
	_ro_label.modulate.a = 1.0 if is_current else 0.0
