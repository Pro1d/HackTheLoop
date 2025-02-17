class_name VLoopContainer
extends Container

var separation := 4.0
var item_height := 96.0
var center_index := 0.0

func center_on_index(index: float) -> void:
	center_index = index
	queue_sort()

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		var control_count := 0
		for c in get_children():
			if c is Control:
				control_count += 1
		
		var index_min := -float(control_count) / 2 + 1e-3 + .5 * (1-control_count % 2)
		var index_max := float(control_count) / 2 + 1e-3 + .5 * (1-control_count % 2)
		var v_offset := size.y * .5
		var centered_offset := 1.0 - .5 * (control_count % 2) # 0.5 to center if odd / 1.0 to not to center is even
		# FIXME center_offset is always .5, and duplicate item and add alpha (or color overlay) to hide item based on distance
		var i := 0
		for child in get_children():
			var c := child as Control
			if c == null: continue
			var cindex := i - center_index
			cindex = wrapf(cindex, index_min, index_max) - centered_offset
			var w := size.x
			var h := item_height #c.get_minimum_size().y
			var py := (h + separation) * cindex + v_offset;
			# Fit to own size
			fit_child_in_rect(c, Rect2(Vector2(0, py), Vector2(w, h)))
			i += 1
