class_name FadeRect
extends ColorRect


var t : Tween

func _ready() -> void:
	show()

func fade_out(duration: float = 2.0) -> void:
	if t != null:
		t.kill()
	t = create_tween()
	show()
	modulate.a = 0.0
	t.tween_property(self, "modulate:a", 1.0, duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await t.finished
		
func fade_in(duration: float = 1.0) -> void:
	if t != null:
		t.kill()
	t = create_tween()
	show()
	modulate.a = 1.0
	t.tween_property(self, "modulate:a", 0.0, duration) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(hide)
	await t.finished
