class_name InstructionUI
extends Control

enum HighlightType {
	NONE,
	FOCUS_INSTR,
	FOCUS_TARGET,
	SELECT_INSTR,
	SELECT_TARGET,
}

@export var instruction : Instruction :
	set(i):
		instruction = i
		_update_content()
@export var is_current : bool = false :
	set(c):
		is_current = c
		_update_current()
@export var highlight_type := HighlightType.NONE :
	set(h):
		if highlight_type != h:
			highlight_type = h
			_update_highlight()
	
const hframes := 4

@onready var _instruction_atlastex := (%InstructionIcon as TextureRect).texture as AtlasTexture
@onready var _target_icon := %TargetIcon as TextureRect
@onready var _target_atlastex := _target_icon.texture as AtlasTexture
@onready var _instruction_panel := %PanelContainer as PanelContainer
@onready var _target_panel := %TargetContainer as PanelContainer
@onready var _current_indicator := %TextureRect as Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_current()
	_update_content()
	_update_highlight()

func _update_current() -> void:
	if _current_indicator == null:
		return
	_current_indicator.visible = is_current

func _update_content() -> void:
	if _target_panel == null or instruction == null:
		return
	InstructionUI._set_frame(instruction.type, _instruction_atlastex)
	InstructionUI._set_frame(instruction.target_type, _target_atlastex)
	_target_icon.modulate = Color.WHITE if instruction.target_is_button() else Config.DARK_INK
	var has_target := instruction.target_type
	_target_panel.visible = has_target

func _update_highlight() -> void:
	if _instruction_panel == null:
		return
	var instr_theme_type_variation := &"PanelContainer_NI"
	var target_theme_type_variation := &"PanelContainer_NT"
	match highlight_type:
		HighlightType.FOCUS_INSTR:
			instr_theme_type_variation = &"PanelContainer_FI"
		HighlightType.FOCUS_TARGET:
			target_theme_type_variation = &"PanelContainer_FT"
		HighlightType.SELECT_INSTR:
			instr_theme_type_variation = &"PanelContainer_SI"
		HighlightType.SELECT_TARGET:
			target_theme_type_variation = &"PanelContainer_ST"
	_instruction_panel.theme_type_variation = instr_theme_type_variation
	_target_panel.theme_type_variation = target_theme_type_variation

static func _set_frame(index: int, atlastex: AtlasTexture) -> void:
	var atlas_size := Vector2i(atlastex.atlas.get_width(), atlastex.atlas.get_height())
	var region_size := Vector2i.ONE * (atlas_size.x / hframes)
	var frame_coords := Vector2i(index % hframes, index / hframes)
	atlastex.region.position = Vector2(region_size * frame_coords)
	atlastex.region.size = Vector2(region_size)

var  _tween_appear : Tween
func animate_appear() -> void:
	if _tween_appear != null:
		_tween_appear.kill()
	_tween_appear = create_tween()
	_tween_appear.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
