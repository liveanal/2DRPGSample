class_name CursorSelectable extends Selectable

@export var cursor:Texture2D:
	set(val):
		cursor = val
	get:
		return cursor
@export var cursor_scale:Vector2:
	set(val):
		cursor_scale = val
	get:
		return cursor_scale
@export var space_size:Vector2:
	set(val):
		space_size = val
	get:
		return space_size

var cursor_tween:Tween

func _ready():
	super._ready()
	connect("changed_index",func(p,n):
		if 0<rows.size() :
			var spos := _next_scroll_pos(rows[n],p>n)
			var cpos := _next_cursor_pos(rows[n])
			_move_scroll(spos)
			_move_cursor(cpos-Vector2(0,spos)))

func _next_cursor_pos(row)->Vector2:
	return Vector2(space_size.x/2 + _pos_row_top(row).x, _pos_row_center(row).y) + _get_margin_size()

func _move_cursor(next_value:Vector2):
	# スクロール開始
	if 0<scroll_speed:
		if cursor_tween!=null and cursor_tween.is_running(): cursor_tween.stop()
		cursor_tween=create_tween()
		cursor_tween.set_ease(Tween.EASE_OUT)
		cursor_tween.set_trans(Tween.TRANS_CUBIC)
		cursor_tween.tween_property($cursor, "position", next_value, scroll_speed)
		cursor_tween.play()
		await cursor_tween.finished
	else:
		$cursor.position = next_value

func set_cursor():
	$cursor.texture = cursor
	$cursor.scale = cursor_scale
	$cursor.position = _next_cursor_pos(rows[index]) if 0<rows.size() else space_size/2 + _get_margin_size()

func set_items(items:Array):
	rows.clear()
	await _clear_rows()
	for item in items:
		var space := Container.new()
		space.custom_minimum_size=space_size
		rows.append(_create_row([space,item]))
	# 行セット
	await _set_rows(rows)
	set_cursor()
