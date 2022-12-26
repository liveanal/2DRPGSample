class_name Selectable extends Scrollable

signal changed_index(before_index,after_index)
signal pressed_accept(index)
signal pressed_cancel

@export_group("Index")
@export var index:=0:
	set(val):
		var before:=int(index)
		index = posmod(val,index_max) if 0<index_max else 0
		emit_signal("changed_index",before,index)
	get:
		return index

@export_group("Input Settings")
@export var input_accept:String = "ui_accept"
@export var input_cancel:String = "ui_cancel"

var scroll_tween:Tween
var index_max:=0

func _input(event):
	if event is InputEventKey:
		if (event.is_pressed or event.is_echo()) and !event.is_action_released(input_up) and event.is_action(input_up):
			index-=1
		elif (event.is_pressed or event.is_echo()) and !event.is_action_released(input_down) and event.is_action(input_down):
			index+=1

		if event.is_action_pressed(input_accept):
			emit_signal("pressed_accept",index)
		
		if event.is_action_pressed(input_cancel):
			emit_signal("pressed_cancel")

func _set_rows(rows:Array):
	await super._set_rows(rows)
	index_max=rows.size()
	index=index

func _move_scroll(next_value:int):
	# スクロール開始
	if 0<scroll_speed:
		if scroll_tween!=null and scroll_tween.is_running(): scroll_tween.stop()
		scroll_tween=create_tween()
		scroll_tween.set_ease(Tween.EASE_OUT)
		scroll_tween.set_trans(Tween.TRANS_CUBIC)
		scroll_tween.tween_property($margin/scroll, "scroll_vertical", next_value, scroll_speed)
		scroll_tween.play()
		await scroll_tween.finished
	else:
		$margin/scroll.scroll_vertical = next_value
