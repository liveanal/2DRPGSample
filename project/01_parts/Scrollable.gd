class_name Scrollable extends Panel

@export_group("Layout Settings")
@export var column_size:int=1:
	set(val):
		column_size = val if 0<val else 1
		$margin/scroll/contents.columns = column_size
	get:
		return column_size
@export var minimum_height:float=0.0:
	set(val):
		minimum_height = val if 0<val else 0
	get:
		return minimum_height
@export_enum(Fill,Begin,Center,End) var size_vertical:int=0:
	set(val):
		size_vertical = val
	get:
		return size_vertical
@export var expand:bool=false:
	set(val):
		expand = val
	get:
		return expand

@export_group("Input Settings")
@export var is_input:bool:
	set(val):
		is_input = val
		set_process_input(is_input)
	get:
		return is_input
@export var input_up:String = "ui_up"
@export var input_down:String = "ui_down"

@export_group("Scroll Setting")
@export var hide_scrollbar:bool=false:
	set(val):
		hide_scrollbar = val
		if hide_scrollbar:
			$margin/scroll.vertical_scroll_mode = 3
		else:
			$margin/scroll.vertical_scroll_mode = 1
	get:
		return hide_scrollbar
@export var scroll_speed:float=1.0

var rows:=[]

func _ready():
	set_process_input(is_input)

func _input(event):
	if event is InputEventKey:
		if (event.is_pressed or event.is_echo()) and !event.is_action_released(input_up) and event.is_action(input_up):
			$margin/scroll.scroll_vertical -= scroll_speed
		elif (event.is_pressed or event.is_echo()) and !event.is_action_released(input_down) and event.is_action(input_down):
			$margin/scroll.scroll_vertical += scroll_speed

func _create_row(item)->HBoxContainer:
	var container := HBoxContainer.new()
	container.custom_minimum_size = Vector2(0,minimum_height)
	container.size_flags_horizontal=SIZE_EXPAND_FILL
	match(size_vertical):
		0: container.size_flags_vertical=SIZE_FILL if !expand else SIZE_EXPAND_FILL
		1: container.size_flags_vertical=SIZE_SHRINK_BEGIN
		2: container.size_flags_vertical=SIZE_SHRINK_CENTER if !expand else SIZE_SHRINK_CENTER+SIZE_EXPAND
		3: container.size_flags_vertical=SIZE_SHRINK_END if !expand else SIZE_SHRINK_END+SIZE_EXPAND
	if item is Array:
		for i in item : container.add_child(i)
	else:
		container.add_child(item)
	return container

func _clear_rows():
	for child in $margin/scroll/contents.get_children():
		child.queue_free()
	await get_tree().process_frame

func _set_rows(rows:Array):
	for row in rows:
		$margin/scroll/contents.add_child(row)
	await get_tree().process_frame

func _pos_row_top(row)->Vector2:
	var result = row.position
	return result

func _pos_row_center(row)->Vector2:
	var result = row.position + row.size/2
	return result

func _pos_row_bottom(row)->Vector2:
	var result = row.position + row.size
	return result

func _pos_scroll_top()->float:
	return $margin/scroll.scroll_vertical

func _pos_scroll_bottom()->float:
	return $margin/scroll.size.y+$margin/scroll.scroll_vertical

func _get_margin_size()->Vector2:
	return Vector2($margin.get("theme_override_constants/margin_left"),$margin.get("theme_override_constants/margin_top"))

func _next_scroll_pos(row, moveup:=false)->int:
	var next_value = $margin/scroll.scroll_vertical
	
	# スクロール位置計算
	if !moveup and _pos_scroll_bottom() < _pos_row_bottom(row).y:
		next_value = _pos_row_bottom(row).y - $margin/scroll.size.y
	elif moveup and _pos_row_top(row).y < _pos_scroll_top():
		next_value = _pos_row_top(row).y
	
	return next_value

func set_items(items:Array):
	rows.clear()
	await _clear_rows()
	add_item(items)

func add_item(item):
	if item is Array:
		for i in item: rows.append(i)
	else:
		rows.append(item)
	# 行セット
	await _set_rows([item])

func scrolling_bottom():
	$margin/scroll.scroll_vertical = _next_scroll_pos(rows.back())

func scrolling_top():
	$margin/scroll.scroll_vertical = _next_scroll_pos(rows.front(),true)
