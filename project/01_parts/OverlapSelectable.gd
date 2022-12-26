class_name OverlapSelectable extends Selectable

@export var cursor:Texture2D:
	set(val):
		cursor = val
	get:
		return cursor
@export var cursor_margin:Vector2:
	set(val):
		cursor_margin = val
	get:
		return cursor_margin
@export var color:Color=Color.WHITE:
	set(val):
		color = val
	get:
		return color

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
	return _pos_row_top(row) + _get_margin_size() - cursor_margin/2

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
	$cursor.size = rows[index].size + cursor_margin if 0<rows.size() else cursor_margin
	$cursor.position = _next_cursor_pos(rows[index]) if 0<rows.size() else  _get_margin_size() - cursor_margin/2
	$cursor.modulate = color

func set_items(items:Array):
	await super.set_items(items)
	set_cursor()
